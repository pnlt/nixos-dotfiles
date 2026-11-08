import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets

ShellRoot {
    id: root

    readonly property string font: "IoskeleyMono Nerd Font Mono"
    readonly property color fg: "#ffffff"
    readonly property color dim: Qt.rgba(1, 1, 1, 0.45)
    readonly property color cyan: "#07aee5"
    readonly property color blue: "#1792d0"
    readonly property color green: "#00d787"
    readonly property color red: "#f7768e"
    readonly property int anim: 110

    property int cpu: 0
    property int ram: 0
    property var lastCpu: [0, 0]

    // /proc reads are in-process, no subprocess per tick
    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            const f = text().split("\n", 1)[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = f[3] + f[4];
            const total = f.reduce((a, b) => a + b, 0);
            const dt = total - root.lastCpu[0];
            if (dt > 0 && root.lastCpu[0] > 0)
                root.cpu = Math.round(100 * (1 - (idle - root.lastCpu[1]) / dt));
            root.lastCpu = [total, idle];
        }
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const t = text();
            const total = Number(t.match(/MemTotal:\s+(\d+)/)[1]);
            const avail = Number(t.match(/MemAvailable:\s+(\d+)/)[1]);
            root.ram = Math.round(100 * (1 - avail / total));
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    property bool tsUp: false
    property var tsDevices: []
    property string tsSelfIp: "—"
    property string tsTailnet: "—"
    readonly property int tsOnline: tsDevices.filter(d => d.online && !d.self).length
    property string tsBuffer: ""

    function tsPoll() {
        if (!tailscale.connected) {
            tsBuffer = "";
            tailscale.connected = true;
        }
    }

    function tsParse(response) {
        const body = response.slice(response.indexOf("\r\n\r\n") + 4);
        let s;
        try {
            if (!response.startsWith("HTTP/1.0 200") && !response.startsWith("HTTP/1.1 200"))
                throw response.split("\r\n", 1)[0];
            s = JSON.parse(body);
        } catch (e) {
            tsUp = false;
            return;
        }
        const now = Date.now() / 1000;
        const icons = { linux: "", macOS: "", iOS: "", android: "", windows: "", freebsd: "" };
        const ago = d => d < 60 ? "just now" : d < 3600 ? `${Math.floor(d / 60)}m ago`
            : d < 86400 ? `${Math.floor(d / 3600)}h ago` : `${Math.floor(d / 86400)}d ago`;
        const mk = (n, self) => {
            const seen = Date.parse(n.LastSeen ?? "") / 1000 || 0;
            const online = self || !!n.Online;
            return {
                name: n.HostName || "device",
                os: n.OS || "unknown",
                icon: icons[n.OS] ?? "",
                ip: n.TailscaleIPs?.[0] ?? "—",
                online, self,
                status: self ? "this device" : online ? "online" : seen > 0 ? ago(now - seen) : "unknown",
                key: online ? now + (self ? 1 : 0) : seen
            };
        };
        tsDevices = [mk(s.Self ?? {}, true), ...Object.values(s.Peer ?? {}).map(p => mk(p, false))]
            .sort((a, b) => b.key - a.key);
        tsSelfIp = s.Self?.TailscaleIPs?.[0] ?? "—";
        tsTailnet = (s.Self?.DNSName ?? "").replace(/\.$/, "").split(".").slice(1).join(".") || "tailnet";
        tsUp = s.BackendState === "Running";
    }

    // LocalAPI over tailscaled's socket; HTTP/1.0 so the daemon closes after the body
    Socket {
        id: tailscale
        path: "/var/run/tailscale/tailscaled.sock"
        parser: SplitParser {
            splitMarker: ""
            onRead: data => root.tsBuffer += data
        }
        onConnectedChanged: {
            if (connected) {
                write("GET /localapi/v0/status HTTP/1.0\r\nHost: local-tailscaled.sock\r\n\r\n");
                flush();
            } else
                root.tsParse(root.tsBuffer);
        }
        // PeerClosedError (1) is the normal end of an HTTP/1.0 response
        onError: e => { if (e !== 1) root.tsUp = false; }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.tsPoll()
    }

    component Label: Text {
        color: root.fg
        font.family: root.font
        font.pixelSize: 13
        font.weight: Font.DemiBold
        verticalAlignment: Text.AlignVCenter
    }

    component Pill: Rectangle {
        default property alias content: row.data
        property alias spacing: row.spacing
        implicitWidth: row.implicitWidth + 20
        implicitHeight: 24
        radius: height / 2
        color: Qt.rgba(1, 1, 1, hover.hovered ? 0.2 : 0.12)
        Behavior on color { ColorAnimation { duration: root.anim } }

        HoverHandler { id: hover }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 8
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property ShellScreen modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 32
            color: Qt.rgba(30 / 255, 32 / 255, 48 / 255, 0.5)

            Row {
                anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
                spacing: 6

                Pill {
                    implicitWidth: implicitHeight + 6
                    Label { text: ""; color: root.blue; font.pixelSize: 18 }
                }

                Pill {
                    id: workspaces
                    spacing: 6
                    readonly property var all: Hyprland.workspaces.values.filter(w => w.id > 0)
                    readonly property int activeId: bar.monitor?.activeWorkspace?.id ?? -1

                    Repeater {
                        model: Math.max(5, ...workspaces.all.map(w => w.id))

                        Rectangle {
                            required property int index
                            readonly property var ws: workspaces.all.find(w => w.id === index + 1)
                            readonly property bool active: index + 1 === workspaces.activeId
                            anchors.verticalCenter: parent.verticalCenter
                            width: active ? 26 : 10
                            height: 10
                            radius: 5
                            color: active ? root.cyan
                                 : ws?.urgent ? root.red
                                 : ws?.toplevels.values.length > 0 ? root.fg
                                 : Qt.rgba(1, 1, 1, 0.22)
                            Behavior on width { NumberAnimation { duration: root.anim; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: root.anim } }

                            MouseArea {
                                anchors { fill: parent; margins: -4 }
                                onClicked: Hyprland.dispatch(`hl.dsp.focus({ workspace = ${parent.index + 1} })`)
                            }
                        }
                    }
                }

                Pill {
                    visible: SystemTray.items.values.length > 0

                    Repeater {
                        model: SystemTray.items

                        IconImage {
                            id: icon
                            required property SystemTrayItem modelData
                            anchors.verticalCenter: parent.verticalCenter
                            implicitSize: 16
                            source: modelData.icon
                            // Symbolic icons are drawn black and vanish on the dark pill
                            layer.enabled: modelData.icon.includes("symbolic")
                            layer.effect: MultiEffect { brightness: 1 }
                            opacity: mouse.containsMouse ? 1 : 0.85
                            Behavior on opacity { NumberAnimation { duration: root.anim } }

                            MouseArea {
                                id: mouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                                onClicked: event => {
                                    const item = icon.modelData;
                                    if (event.button === Qt.MiddleButton)
                                        item.secondaryActivate();
                                    else if (event.button === Qt.RightButton || item.onlyMenu) {
                                        if (item.hasMenu) {
                                            const p = icon.mapToItem(null, 0, icon.height + 8);
                                            item.display(bar, p.x, p.y);
                                        }
                                    } else
                                        item.activate();
                                }
                            }
                        }
                    }
                }
            }

            Pill {
                anchors.centerIn: parent
                Label { text: ""; color: root.cyan }
                Label { text: Qt.formatDateTime(clock.date, "ddd dd  HH:mm") }
            }

            Row {
                anchors { right: parent.right; rightMargin: 6; verticalCenter: parent.verticalCenter }
                spacing: 6

                Pill {
                    id: tsPill
                    spacing: 6
                    Label { text: ""; color: root.tsUp ? root.cyan : root.dim }
                    Label {
                        text: root.tsUp ? `${root.tsOnline}/${root.tsDevices.length - 1}` : "off"
                        color: root.tsUp ? root.fg : root.dim
                    }

                    TapHandler {
                        onTapped: {
                            if (!tsPanel.visible) {
                                root.tsPoll();
                                tsPanel.anchor.rect.x = Math.min(tsPill.mapToItem(null, 0, 0).x, bar.width - tsPanel.width - 6);
                            }
                            tsPanel.visible = !tsPanel.visible;
                        }
                    }
                }

                Pill {
                    spacing: 6
                    Label { text: ""; color: root.cpu >= 90 ? root.red : root.green }
                    Label { text: `${root.cpu}%` }
                    Item { width: 4; height: 1 }
                    Label { text: "\u{f035b}"; color: root.ram >= 90 ? root.red : root.blue }
                    Label { text: `${root.ram}%` }
                }
            }

            PopupWindow {
                id: tsPanel
                anchor.window: bar
                anchor.rect.y: bar.height + 4
                implicitWidth: 320
                implicitHeight: panel.implicitHeight
                grabFocus: true
                color: "transparent"

                Rectangle {
                    id: panel
                    width: parent.width
                    implicitHeight: content.implicitHeight + 28
                    radius: 10
                    color: Qt.rgba(26 / 255, 27 / 255, 38 / 255, 0.96)
                    border.width: 1
                    border.color: "#414868"
                    opacity: tsPanel.visible ? 1 : 0
                    y: tsPanel.visible ? 0 : -6
                    Behavior on opacity { NumberAnimation { duration: root.anim } }
                    Behavior on y { NumberAnimation { duration: root.anim; easing.type: Easing.OutCubic } }

                    Column {
                        id: content
                        anchors { fill: parent; margins: 14 }
                        spacing: 10

                        Item {
                            width: parent.width
                            height: 36

                            Label {
                                id: mark
                                text: ""
                                font.pixelSize: 26
                                height: parent.height
                                color: root.tsUp ? root.cyan : root.dim
                            }
                            Column {
                                anchors { left: mark.right; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                Label { text: "Tailscale"; font.pixelSize: 16; color: root.cyan }
                                Label {
                                    text: root.tsUp ? `${root.tsOnline}/${root.tsDevices.length - 1} online · ${root.tsTailnet}` : "disconnected"
                                    color: "#9aa5ce"
                                    font.pixelSize: 11
                                    font.weight: Font.Normal
                                }
                            }
                            Label {
                                anchors { right: parent.right; top: parent.top }
                                text: root.tsSelfIp
                                color: root.green
                                font.pixelSize: 11
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: "#414868" }

                        ListView {
                            width: parent.width
                            height: Math.min(contentHeight, 280)
                            clip: true
                            spacing: 5
                            boundsBehavior: Flickable.StopAtBounds
                            model: root.tsDevices

                            delegate: Rectangle {
                                required property var modelData
                                width: ListView.view.width
                                height: 44
                                radius: 6
                                color: modelData.self ? "#2f3549" : "#24283b"

                                Rectangle {
                                    width: 3
                                    height: parent.height - 12
                                    anchors { left: parent.left; leftMargin: 1; verticalCenter: parent.verticalCenter }
                                    radius: 2
                                    color: modelData.online ? root.green : "#414868"
                                }
                                Label {
                                    id: os
                                    anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                                    width: 24
                                    text: modelData.icon
                                    font.pixelSize: 20
                                    color: modelData.online ? root.cyan : "#565f89"
                                }
                                Column {
                                    anchors { left: os.right; leftMargin: 8; right: right.left; rightMargin: 8; verticalCenter: parent.verticalCenter }
                                    Label { width: parent.width; text: modelData.name; elide: Text.ElideRight }
                                    Label {
                                        text: `${modelData.os} · ${modelData.ip}`
                                        color: "#9aa5ce"
                                        font.pixelSize: 11
                                        font.weight: Font.Normal
                                    }
                                }
                                Column {
                                    id: right
                                    anchors { right: parent.right; rightMargin: 10; verticalCenter: parent.verticalCenter }
                                    Label {
                                        anchors.right: parent.right
                                        text: modelData.online ? "●" : "○"
                                        font.pixelSize: 11
                                        color: modelData.online ? root.green : "#565f89"
                                    }
                                    Label {
                                        text: modelData.status
                                        color: "#9aa5ce"
                                        font.pixelSize: 11
                                        font.weight: Font.Normal
                                    }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: "#414868" }

                        Row {
                            width: parent.width
                            spacing: 8

                            Repeater {
                                model: [
                                    { label: "refresh", run: () => root.tsPoll() },
                                    { label: "admin panel", run: () => {
                                        tsPanel.visible = false;
                                        Qt.openUrlExternally("https://login.tailscale.com/admin/machines");
                                    } }
                                ]

                                Rectangle {
                                    required property var modelData
                                    width: (parent.width - 8) / 2
                                    height: 28
                                    radius: 6
                                    color: hover.containsMouse ? "#414868" : "#24283b"
                                    Behavior on color { ColorAnimation { duration: root.anim } }

                                    Label { anchors.centerIn: parent; text: modelData.label; font.pixelSize: 12 }
                                    MouseArea {
                                        id: hover
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: parent.modelData.run()
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
