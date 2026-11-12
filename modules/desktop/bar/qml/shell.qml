import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Services.SystemTray
import Quickshell.Wayland
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

    property var history: []
    property bool historyLoaded: false
    property int unread: 0
    property bool dnd: false
    property bool flash: false
    property bool centerOpen: false
    readonly property ShellScreen focusedScreen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]

    // pile rules: these never pop up, they only land in the centre and flash the bell
    readonly property var silent: [
        { app: /claude|codex|gemini|opencode|aider|cursor|copilot|herdr/i },
        { app: /^notify-send$/i, summary: /\b(claude|codex|gemini|opencode|aider)\b/i },
        { app: /grimblast|hyprshot/i }
    ]
    // OSD readouts pop up but are not worth keeping
    readonly property var ignored: [{ app: /^dunstify$/i }]

    function matches(rules, n) {
        return rules.some(r => (!r.app || r.app.test(n.appName)) && (!r.summary || r.summary.test(n.summary)));
    }

    // image-path hints arrive as image://icon/<name or path>, which skips the missing-icon check
    function iconSource(i) {
        i = i.replace(/^image:\/\/icon\//, "");
        return !i ? "" : i.startsWith("/") ? `file://${i}` : i.includes("://") ? i : Quickshell.iconPath(i, true);
    }

    function since(t) {
        const m = (clock.date - t) / 60000;
        return m < 1 ? "now" : m < 60 ? `${Math.floor(m)}m` : m < 1440 ? `${Math.floor(m / 60)}h`
            : Qt.formatDateTime(new Date(t), "ddd HH:mm");
    }

    function toggleCenter() {
        centerOpen = !centerOpen;
        if (centerOpen)
            unread = 0;
    }

    onHistoryChanged: if (historyLoaded) store.setText(JSON.stringify(history))

    FileView {
        id: store
        path: Quickshell.statePath("notifications.json")
        printErrors: false
        onLoaded: {
            try {
                root.history = JSON.parse(text());
            } catch (e) {}
            root.historyLoaded = true;
        }
        onLoadFailed: root.historyLoaded = true
    }

    Timer {
        id: flashTimer
        interval: 2000
        onTriggered: root.flash = false
    }

    NotificationServer {
        id: server
        imageSupported: true
        actionsSupported: true
        bodyMarkupSupported: true

        onNotification: n => {
            const quiet = root.matches(root.silent, n);
            if (!n.lastGeneration && !n.transient && !root.matches(root.ignored, n)) {
                root.history = [{
                    app: n.appName, summary: n.summary, body: n.body,
                    icon: n.image.startsWith("image://icon/") ? n.image : n.appIcon,
                    time: Date.now(), quiet, critical: n.urgency === NotificationUrgency.Critical
                }, ...root.history].slice(0, 50);
                if (!root.centerOpen)
                    root.unread++;
                if (quiet) {
                    root.flash = true;
                    flashTimer.restart();
                }
            }
            if (quiet || root.dnd && n.urgency !== NotificationUrgency.Critical)
                return;
            n.tracked = true;
            const live = server.trackedNotifications.values;
            if (live.length > 4)
                live[0].expire();
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { root.toggleCenter(); }
        function toggleDnd(): void { root.dnd = !root.dnd; }
        function clear(): void { root.history = []; }
    }

    Overview {}

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
        color: Qt.rgba(22 / 255, 38 / 255, 51 / 255, hover.hovered ? 0.95 : 0.75)
        Behavior on color { ColorAnimation { duration: root.anim } }

        HoverHandler { id: hover }
        Row {
            id: row
            anchors.centerIn: parent
            spacing: 8
        }
    }

    component Card: Rectangle {
        id: card
        property string icon
        property string app
        property string summary
        property string body
        property string stamp
        property color accent: root.cyan
        readonly property alias hovered: cardHover.hovered
        default property alias extra: col.data
        signal clicked
        signal closed

        implicitHeight: Math.max(col.implicitHeight, 32) + 22
        radius: 8
        color: hovered ? "#2f3549" : "#24283b"
        border.width: 1
        border.color: "#414868"
        Behavior on color { ColorAnimation { duration: root.anim } }

        HoverHandler { id: cardHover }
        MouseArea {
            anchors.fill: parent
            onClicked: card.clicked()
        }

        Rectangle {
            width: 3
            height: parent.height - 16
            anchors { left: parent.left; leftMargin: 1; verticalCenter: parent.verticalCenter }
            radius: 2
            color: card.accent
        }
        IconImage {
            id: img
            x: 14
            y: 11
            implicitSize: 32
            source: root.iconSource(card.icon)
            visible: source != ""
        }
        Column {
            id: col
            anchors {
                left: img.visible ? img.right : parent.left
                leftMargin: img.visible ? 10 : 14
                right: parent.right
                rightMargin: 30
                top: parent.top
                topMargin: 11
            }
            spacing: 2

            Label {
                width: parent.width
                text: [card.app, card.stamp].filter(Boolean).join(" · ")
                color: "#9aa5ce"
                font.pixelSize: 11
                font.weight: Font.Normal
                elide: Text.ElideRight
            }
            Label {
                width: parent.width
                text: card.summary
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
            Label {
                width: parent.width
                visible: text !== ""
                text: card.body
                color: "#c0caf5"
                font.pixelSize: 12
                font.weight: Font.Normal
                wrapMode: Text.Wrap
                maximumLineCount: 4
                elide: Text.ElideRight
                textFormat: Text.StyledText
            }
        }
        Label {
            anchors { right: parent.right; rightMargin: 10; top: parent.top; topMargin: 9 }
            text: "\u{f0156}"
            color: closeArea.containsMouse ? root.red : "#565f89"
            opacity: card.hovered ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: root.anim } }
            MouseArea {
                id: closeArea
                anchors { fill: parent; margins: -4 }
                hoverEnabled: true
                onClicked: card.closed()
            }
        }
    }

    component Button: Rectangle {
        property alias text: label.text
        signal clicked
        implicitWidth: label.implicitWidth + 20
        implicitHeight: 26
        radius: 6
        color: buttonArea.containsMouse ? "#414868" : "#24283b"
        Behavior on color { ColorAnimation { duration: root.anim } }

        Label { id: label; anchors.centerIn: parent; font.pixelSize: 12 }
        MouseArea {
            id: buttonArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: parent.clicked()
        }
    }

    PanelWindow {
        screen: root.focusedScreen
        visible: server.trackedNotifications.values.length > 0 && !root.centerOpen
        anchors { top: true; right: true }
        margins { top: 6; right: 6 }
        exclusionMode: ExclusionMode.Normal
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"
        implicitWidth: 360
        implicitHeight: popups.implicitHeight
        color: "transparent"

        Column {
            id: popups
            width: parent.width
            spacing: 6

            Repeater {
                model: server.trackedNotifications

                Card {
                    id: popup
                    required property Notification modelData
                    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical
                    width: popups.width
                    icon: modelData.image || modelData.appIcon
                    app: modelData.appName
                    summary: modelData.summary
                    body: modelData.body
                    stamp: "now"
                    accent: critical ? root.red : root.matches(root.ignored, modelData) ? "#414868" : root.cyan
                    onClicked: {
                        const action = modelData.actions.find(a => a.identifier === "default");
                        if (action)
                            action.invoke();
                        else
                            modelData.dismiss();
                    }
                    onClosed: modelData.dismiss()

                    NumberAnimation on x { from: 40; to: 0; duration: root.anim * 2; easing.type: Easing.OutCubic }
                    NumberAnimation on opacity { from: 0; to: 1; duration: root.anim * 2 }

                    Timer {
                        running: !popup.hovered && !popup.critical
                        interval: popup.modelData.expireTimeout > 0 ? popup.modelData.expireTimeout * 1000 : 6000
                        onTriggered: popup.modelData.expire()
                    }

                    Row {
                        visible: popup.modelData.actions.length > 0
                        topPadding: 6
                        spacing: 6

                        Repeater {
                            model: popup.modelData.actions.filter(a => a.identifier !== "default")

                            Button {
                                required property NotificationAction modelData
                                text: modelData.text
                                onClicked: modelData.invoke()
                            }
                        }
                    }
                }
            }
        }
    }

    PanelWindow {
        screen: root.focusedScreen
        visible: root.centerOpen
        anchors { top: true; right: true }
        margins { top: 6; right: 6 }
        exclusionMode: ExclusionMode.Normal
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notification-center"
        implicitWidth: 380
        implicitHeight: center.implicitHeight
        color: "transparent"

        Rectangle {
            id: center
            width: parent.width
            implicitHeight: centerContent.implicitHeight + 28
            radius: 10
            color: Qt.rgba(26 / 255, 27 / 255, 38 / 255, 0.96)
            border.width: 1
            border.color: "#414868"

            Column {
                id: centerContent
                anchors { fill: parent; margins: 14 }
                spacing: 10

                Item {
                    width: parent.width
                    height: 26

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        text: `Notifications  <font color="#9aa5ce">${root.history.length}</font>`
                        textFormat: Text.StyledText
                        font.pixelSize: 15
                        color: root.cyan
                    }
                    Row {
                        anchors.right: parent.right
                        spacing: 6
                        Button {
                            text: root.dnd ? "\u{f009b}  dnd on" : "\u{f009a}  dnd off"
                            onClicked: root.dnd = !root.dnd
                        }
                        Button {
                            text: "clear"
                            onClicked: root.history = []
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: "#414868" }

                Label {
                    visible: root.history.length === 0
                    width: parent.width
                    height: 60
                    horizontalAlignment: Text.AlignHCenter
                    text: "all caught up"
                    color: "#565f89"
                }

                ListView {
                    visible: root.history.length > 0
                    width: parent.width
                    height: Math.min(contentHeight, root.focusedScreen.height * 0.7)
                    clip: true
                    spacing: 6
                    boundsBehavior: Flickable.StopAtBounds
                    model: root.history

                    delegate: Card {
                        required property var modelData
                        required property int index
                        width: ListView.view.width
                        icon: modelData.icon
                        app: modelData.app
                        summary: modelData.summary
                        body: modelData.body
                        stamp: root.since(modelData.time)
                        accent: modelData.critical ? root.red : modelData.quiet ? root.green : root.cyan
                        onClosed: root.history = root.history.filter((_, i) => i !== index)
                    }
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens.filter(s => s.name === "DP-2")

        PanelWindow {
            id: bar
            required property ShellScreen modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(modelData)

            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 32
            color: "transparent"

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
                    spacing: 6
                    Label {
                        text: root.dnd ? "\u{f009b}" : "\u{f009a}"
                        color: root.flash ? root.red : root.unread > 0 ? root.cyan : root.dim
                        Behavior on color { ColorAnimation { duration: root.anim } }
                    }
                    Label {
                        visible: root.unread > 0
                        text: root.unread
                        color: root.flash ? root.red : root.fg
                    }

                    TapHandler { onTapped: root.toggleCenter() }
                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: root.dnd = !root.dnd
                    }
                }

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

                            Button {
                                width: (parent.width - 8) / 2
                                height: 28
                                text: "refresh"
                                onClicked: root.tsPoll()
                            }
                            Button {
                                width: (parent.width - 8) / 2
                                height: 28
                                text: "admin panel"
                                onClicked: {
                                    tsPanel.visible = false;
                                    Qt.openUrlExternally("https://login.tailscale.com/admin/machines");
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
