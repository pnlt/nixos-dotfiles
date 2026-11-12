import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

// niri-style overview: workspaces stacked vertically with live windows.
// It never takes the keyboard: the real window keeps focus, so every Hyprland bind works
// live, and the "overview" submap (bar.nix) gives bare keys their meaning while it is open.
Scope {
    id: ov

    property bool open: false
    readonly property color cyan: "#07aee5"
    readonly property color card: Qt.rgba(22 / 255, 38 / 255, 51 / 255, 1)
    readonly property real zoom: 0.5
    readonly property int duration: 260

    function setOpen(value) {
        if (value === open)
            return;
        if (value)
            Hyprland.refreshToplevels();
        open = value;
        dispatch(`hl.dsp.submap("${value ? "overview" : "reset"}")`);
    }

    function dispatch(lua) {
        Hyprland.dispatch(lua);
    }

    GlobalShortcut {
        name: "overview"
        description: "Toggle workspace overview"
        onPressed: ov.setOpen(!ov.open)
    }

    // The submap resets itself on these keys, so they still get you out if this shell is gone.
    GlobalShortcut {
        name: "overview-close"
        description: "Close workspace overview"
        onPressed: ov.setOpen(false)
    }

    IpcHandler {
        target: "overview"
        function toggle(): void { ov.setOpen(!ov.open); }
    }

    // Geometry only arrives through refreshToplevels, and layout moves like swapcol emit no
    // event, so poll as well while shown.
    Connections {
        target: Hyprland
        enabled: win.visible
        function onRawEvent(event) { refresh.restart(); }
    }

    Timer {
        id: refresh
        interval: 16
        onTriggered: Hyprland.refreshToplevels()
    }

    Timer {
        interval: 100
        repeat: true
        running: win.visible
        onTriggered: Hyprland.refreshToplevels()
    }

    PanelWindow {
        id: win

        readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)
        readonly property real cardW: width * ov.zoom
        readonly property real cardH: height * ov.zoom
        readonly property real gap: 40
        readonly property var spaces: Hyprland.workspaces.values
            .filter(w => w.id > 0 && w.monitor?.name === screen?.name)
            .sort((a, b) => a.id - b.id)
        readonly property int activeIndex: Math.max(0, spaces.findIndex(w => w.id === monitor?.activeWorkspace?.id))

        property real progress: ov.open ? 1 : 0
        Behavior on progress {
            NumberAnimation { id: zoomAnim; duration: ov.duration; easing.type: Easing.OutQuart }
        }

        screen: Quickshell.screens.find(s => s.name === "DP-2") ?? Quickshell.screens[0]
        visible: ov.open || progress > 0
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:overview"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Rectangle {
            anchors.fill: parent
            color: "#000101"
            opacity: 0.94 * win.progress
        }

        MouseArea {
            anchors.fill: parent
            onClicked: ov.setOpen(false)
        }

        WheelHandler {
            property real acc: 0
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: e => {
                acc += e.angleDelta.y;
                if (Math.abs(acc) < 120)
                    return;
                ov.dispatch(`hl.dsp.focus({ workspace = "${acc < 0 ? "r+1" : "r-1"}" })`);
                acc = 0;
            }
        }

        // At progress 0 the active card is scaled to cover the screen exactly, so the
        // zoom starts and ends on the live desktop underneath.
        Item {
            id: stage
            anchors.fill: parent
            scale: 1 / ov.zoom + (1 - 1 / ov.zoom) * win.progress

            Item {
                x: (stage.width - win.cardW) / 2
                y: (stage.height - win.cardH) / 2 - win.activeIndex * (win.cardH + win.gap)
                Behavior on y {
                    enabled: !zoomAnim.running
                    NumberAnimation { duration: ov.duration; easing.type: Easing.OutQuart }
                }

                Repeater {
                    model: win.spaces

                    Item {
                        id: space
                        required property HyprlandWorkspace modelData
                        required property int index
                        readonly property bool current: index === win.activeIndex
                        y: index * (win.cardH + win.gap)
                        width: win.cardW
                        height: win.cardH

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: ov.card
                            opacity: 0.35 * win.progress
                        }

                        Rectangle {
                            anchors { fill: parent; margins: -3 }
                            radius: 12
                            color: "transparent"
                            border.width: 2
                            border.color: Qt.rgba(1, 1, 1, space.current ? 0.3 : 0.08)
                            opacity: win.progress
                            Behavior on border.color { ColorAnimation { duration: ov.duration } }
                        }

                        Text {
                            anchors { left: parent.left; bottom: parent.top; bottomMargin: 8 }
                            text: space.modelData.name
                            color: Qt.rgba(1, 1, 1, space.current ? 0.9 : 0.45)
                            font { family: "IoskeleyMono Nerd Font Mono"; pixelSize: 14; weight: Font.DemiBold }
                            opacity: win.progress
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                ov.dispatch(`hl.dsp.focus({ workspace = ${space.modelData.id} })`);
                                ov.setOpen(false);
                            }
                        }

                        Repeater {
                            model: Hyprland.toplevels.values.filter(t => t.workspace?.id === space.modelData.id)

                            Item {
                                id: client
                                required property HyprlandToplevel modelData
                                readonly property var ipc: modelData.lastIpcObject
                                readonly property bool placed: !!ipc.at
                                visible: placed
                                // Columns scrolled off-screen land outside the card, like niri's strip.
                                x: placed ? (ipc.at[0] - (win.monitor?.x ?? 0)) * ov.zoom : 0
                                y: placed ? (ipc.at[1] - (win.monitor?.y ?? 0)) * ov.zoom : 0
                                width: placed ? ipc.size[0] * ov.zoom : 0
                                height: placed ? ipc.size[1] * ov.zoom : 0
                                z: ipc.floating ? 1 : 0

                                Behavior on x { enabled: !zoomAnim.running; NumberAnimation { duration: ov.duration; easing.type: Easing.OutQuart } }
                                Behavior on y { enabled: !zoomAnim.running; NumberAnimation { duration: ov.duration; easing.type: Easing.OutQuart } }
                                Behavior on width { enabled: !zoomAnim.running; NumberAnimation { duration: ov.duration; easing.type: Easing.OutQuart } }
                                Behavior on height { enabled: !zoomAnim.running; NumberAnimation { duration: ov.duration; easing.type: Easing.OutQuart } }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: ov.card
                                    border.color: Qt.rgba(1, 1, 1, 0.1)
                                    visible: !shot.hasContent
                                    opacity: win.progress

                                    Text {
                                        anchors.centerIn: parent
                                        width: parent.width - 16
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                        text: client.ipc.class ?? ""
                                        color: Qt.rgba(1, 1, 1, 0.45)
                                        font { family: "IoskeleyMono Nerd Font Mono"; pixelSize: 13 }
                                    }
                                }

                                ScreencopyView {
                                    id: shot
                                    anchors.fill: parent
                                    captureSource: win.visible ? client.modelData.wayland : null
                                    live: true
                                }

                                Rectangle {
                                    anchors { fill: parent; margins: -2 }
                                    radius: 4
                                    color: "transparent"
                                    border.width: 2
                                    border.color: ov.cyan
                                    opacity: client.modelData.activated ? win.progress : 0
                                    Behavior on opacity { NumberAnimation { duration: ov.duration / 2 } }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                                    onClicked: e => {
                                        const target = `address:0x${client.modelData.address}`;
                                        if (e.button === Qt.MiddleButton)
                                            ov.dispatch(`hl.dsp.window.close({ window = "${target}" })`);
                                        else {
                                            ov.dispatch(`hl.dsp.focus({ window = "${target}" })`);
                                            ov.setOpen(false);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
