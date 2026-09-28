import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// ═══════════════════════════════════════════════════════════════════
// Sovereign Power Overlay — Tam ekran glassmorphism güç menüsü
// Grid layout, onay animasyonu, Esc ile iptal
// ═══════════════════════════════════════════════════════════════════
PanelWindow {
    id: root
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "sovereign-power"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors { top: true; bottom: true; left: true; right: true }
    visible: GlobalStates.powerMenuOpen
    color:   "transparent"

    property string pendingAction: ""
    property int    confirmCountdown: 0

    onVisibleChanged: {
        if (visible) {
            pendingAction = ""
            confirmCountdown = 0
            focusScope.forceActiveFocus()
        }
    }

    // ── Countdown Timer ──────────────────────────────────────────────
    Timer {
        id: confirmTimer
        interval: 1000
        repeat: true
        running: root.confirmCountdown > 0
        onTriggered: {
            root.confirmCountdown--
            if (root.confirmCountdown <= 0) {
                executeAction(root.pendingAction)
            }
        }
    }

    function requestAction(action) {
        if (action === "lock") {
            // Kilitleme onay gerektirmez
            executeAction(action)
            return
        }
        root.pendingAction = action
        root.confirmCountdown = 3
    }

    function cancelAction() {
        root.pendingAction = ""
        root.confirmCountdown = 0
    }

    function executeAction(action) {
        root.confirmCountdown = 0
        root.pendingAction = ""
        GlobalStates.powerMenuOpen = false

        switch (action) {
            case "lock":     lockProc.running = true; break
            case "logout":   logoutProc.running = true; break
            case "reboot":   rebootProc.running = true; break
            case "shutdown": shutdownProc.running = true; break
        }
    }

    Process { id: lockProc;     command: ["hyprlock"];              running: false }
    Process { id: logoutProc;   command: ["uwsm", "stop"];         running: false }
    Process { id: rebootProc;   command: ["systemctl", "reboot"];   running: false }
    Process { id: shutdownProc; command: ["systemctl", "poweroff"]; running: false }

    // ── Backdrop ─────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)

        opacity: root.visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 300 } }

        TapHandler { onTapped: { root.cancelAction(); GlobalStates.powerMenuOpen = false } }
    }

    // ── Keyboard Handler ─────────────────────────────────────────────
    FocusScope {
        id: focusScope
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                if (root.pendingAction !== "") {
                    root.cancelAction()
                } else {
                    GlobalStates.powerMenuOpen = false
                }
                event.accepted = true
            }
        }
    }

    // ── Power Grid ───────────────────────────────────────────────────
    Item {
        anchors.centerIn: parent
        width: 520
        height: contentCol.implicitHeight

        // Giriş animasyonu
        scale: root.visible ? 1.0 : 0.8
        opacity: root.visible ? 1.0 : 0.0
        Behavior on scale   { NumberAnimation { duration: 350; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 250 } }

        ColumnLayout {
            id: contentCol
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24

            // Header
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "⏻"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 36
                    color: root.pendingAction !== "" ? Colors.red : Colors.text
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.pendingAction !== ""
                        ? root.confirmCountdown + " saniye içinde " + getActionName(root.pendingAction) + "..."
                        : "Ne yapmak istersiniz?"
                    font.family: "Inter"
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    color: root.pendingAction !== "" ? Colors.red : Colors.subtext
                }

                // Cancel button (onay modunda)
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    visible: root.pendingAction !== ""
                    width: cancelContent.implicitWidth + 32
                    height: 32
                    radius: 10
                    color: cancelBtnHover.hovered
                        ? Qt.rgba(1, 1, 1, 0.10)
                        : Qt.rgba(1, 1, 1, 0.05)
                    border.color: Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1

                    Row {
                        id: cancelContent
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "Esc"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: Colors.text
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "İptal"
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: Colors.subtext
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    HoverHandler { id: cancelBtnHover }
                    TapHandler { onTapped: root.cancelAction() }
                }
            }

            // Button Grid
            GridLayout {
                Layout.alignment: Qt.AlignHCenter
                columns: 4
                columnSpacing: 16
                rowSpacing: 16

                // Lock
                PowerButton {
                    icon: "󰌾"
                    label: "Kilitle"
                    accentColor: Colors.blue
                    enabled: root.pendingAction === ""
                    onClicked: root.requestAction("lock")
                }

                // Logout
                PowerButton {
                    icon: "󰍃"
                    label: "Çıkış"
                    accentColor: Colors.yellow
                    isActive: root.pendingAction === "logout"
                    countdown: root.pendingAction === "logout" ? root.confirmCountdown : 0
                    enabled: root.pendingAction === "" || root.pendingAction === "logout"
                    onClicked: {
                        if (root.pendingAction === "logout") root.executeAction("logout")
                        else root.requestAction("logout")
                    }
                }

                // Reboot
                PowerButton {
                    icon: "󰑐"
                    label: "Yeniden Başlat"
                    accentColor: Colors.peach
                    isActive: root.pendingAction === "reboot"
                    countdown: root.pendingAction === "reboot" ? root.confirmCountdown : 0
                    enabled: root.pendingAction === "" || root.pendingAction === "reboot"
                    onClicked: {
                        if (root.pendingAction === "reboot") root.executeAction("reboot")
                        else root.requestAction("reboot")
                    }
                }

                // Shutdown
                PowerButton {
                    icon: "󰐥"
                    label: "Kapat"
                    accentColor: Colors.red
                    isActive: root.pendingAction === "shutdown"
                    countdown: root.pendingAction === "shutdown" ? root.confirmCountdown : 0
                    enabled: root.pendingAction === "" || root.pendingAction === "shutdown"
                    onClicked: {
                        if (root.pendingAction === "shutdown") root.executeAction("shutdown")
                        else root.requestAction("shutdown")
                    }
                }
            }
        }
    }

    function getActionName(action) {
        switch (action) {
            case "logout":   return "çıkış yapılacak"
            case "reboot":   return "yeniden başlatılacak"
            case "shutdown": return "kapatılacak"
            default: return ""
        }
    }

    // ── Power Button Component ───────────────────────────────────────
    component PowerButton: Rectangle {
        id: btn
        property string icon: ""
        property string label: ""
        property color accentColor: Colors.cyan
        property bool isActive: false
        property int countdown: 0

        signal clicked()

        width:  110
        height: 110
        radius: 20
        color:  {
            if (isActive) return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.18)
            if (btnHover.hovered && enabled) return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.10)
            return Qt.rgba(0.118, 0.118, 0.180, 0.75)
        }
        border.color: {
            if (isActive) return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.55)
            if (btnHover.hovered && enabled) return Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.30)
            return Qt.rgba(1, 1, 1, 0.08)
        }
        border.width: isActive ? 2 : 1
        opacity: enabled ? 1.0 : 0.35

        Behavior on color        { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }
        Behavior on opacity      { NumberAnimation { duration: 200 } }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: btn.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 32
                color: btn.isActive || (btnHover.hovered && btn.enabled)
                    ? btn.accentColor : Colors.text
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: btn.countdown > 0 ? btn.label + " (" + btn.countdown + ")" : btn.label
                font.family: "Inter"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: btn.isActive ? btn.accentColor : Colors.subtext
            }
        }

        // Onay progress ring (countdown görsel)
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: Qt.rgba(btn.accentColor.r, btn.accentColor.g, btn.accentColor.b, 0.30)
            border.width: btn.isActive ? 3 : 0
            visible: btn.isActive

            Behavior on border.width { NumberAnimation { duration: 200 } }
        }

        HoverHandler { id: btnHover }
        TapHandler { onTapped: if (btn.enabled) btn.clicked() }
    }
}
