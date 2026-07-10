import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

PanelWindow {
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "sysinfo-popup"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { top: true; right: true; bottom: false; left: false }
    margins.top:   Appearance.size.barH + Appearance.size.marginTop + 6
    margins.right: Appearance.size.marginSide

    visible: GlobalStates.sysInfoOpen
    color:   "transparent"

    implicitWidth:  340
    implicitHeight: col.implicitHeight + 40

    // Glassmorphism Background (Colors.qml'den)
    Rectangle {
        anchors.fill: parent
        radius:       Appearance.size.radius + 6
        color:        Colors.glass
        border.color: Colors.glassBorder
        border.width: 1
    }

    ColumnLayout {
        id: col
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 20 }
        spacing: 24

        // ── HEADER ──
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Sovereign Hub"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                font.weight: Font.Bold
                color: Colors.text
                Layout.fillWidth: true
            }
            Text {
                text: "󰒲"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                TapHandler { onTapped: GlobalStates.sysInfoOpen = false }
                
                HoverHandler { id: closeHover }
                scale: closeHover.hovered ? 1.1 : 1.0
                Behavior on scale { NumberAnimation { duration: 150 } }
                color: closeHover.hovered ? Colors.red : Colors.subtext
            }
        }

        // ── QUICK TOGGLES ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Wi-Fi (Aktif)
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 12
                color: Colors.blue
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 22; color: Colors.base; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Wi-Fi"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.weight: Font.Bold; color: Colors.base; Layout.alignment: Qt.AlignHCenter }
                }
            }
            // Bluetooth (Pasif)
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 12
                color: Colors.surface0
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 22; color: Colors.text; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Bluetooth"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.weight: Font.Bold; color: Colors.text; Layout.alignment: Qt.AlignHCenter }
                }
                HoverHandler { id: btHover }
                border.color: btHover.hovered ? Colors.surface1 : "transparent"
                border.width: 1
            }
            // Zen Mode (Dinamik Lua Tetikleyicisi)
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 12
                color: GlobalStates.zenMode ? Colors.mauve : Colors.surface0
                Behavior on color { ColorAnimation { duration: 200 } }
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "󰘚"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 22; color: GlobalStates.zenMode ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Zen Mode"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 10; font.weight: Font.Bold; color: GlobalStates.zenMode ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter }
                }
                HoverHandler { id: zenHover }
                border.color: zenHover.hovered ? Colors.surface1 : "transparent"
                border.width: 1

                TapHandler {
                    onTapped: {
                        GlobalStates.zenMode = !GlobalStates.zenMode;
                        Quickshell.execDetached(["notify-send", "Zen Mode", GlobalStates.zenMode ? "Açık (Manuel)" : "Kapalı", "-t", "1500"])
                    }
                }
            }
        }

        // ── DIVIDER ──
        Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1,1,1,0.08) }

        // ── SYSTEM MONITOR ──
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16

            // CPU
            RowLayout {
                spacing: 12
                Text { text: "󰻠"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.teal; Layout.preferredWidth: 20; horizontalAlignment: Text.AlignHCenter }
                Text { text: "CPU"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.subtext; Layout.preferredWidth: 35 }
                Rectangle {
                    Layout.fillWidth: true; height: 8; radius: 4; color: Colors.surface0
                    Rectangle {
                        width: parent.width * (SysInfoService.cpuUsage / 100)
                        height: parent.height; radius: parent.radius; color: Colors.teal
                        Behavior on width { NumberAnimation { duration: Appearance.anim.cpu.dur; easing.type: Easing.OutCubic } }
                    }
                }
                Text { text: SysInfoService.cpuUsage + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.teal; Layout.preferredWidth: 35; horizontalAlignment: Text.AlignRight }
            }

            // GPU
            RowLayout {
                spacing: 12
                Text { text: "󰾲"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.green; Layout.preferredWidth: 20; horizontalAlignment: Text.AlignHCenter }
                Text { text: "GPU"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.subtext; Layout.preferredWidth: 35 }
                Rectangle {
                    Layout.fillWidth: true; height: 8; radius: 4; color: Colors.surface0
                    Rectangle {
                        width: parent.width * (SysInfoService.gpuUsage / 100)
                        height: parent.height; radius: parent.radius; color: Colors.green
                        Behavior on width { NumberAnimation { duration: Appearance.anim.cpu.dur; easing.type: Easing.OutCubic } }
                    }
                }
                Text { text: SysInfoService.gpuUsage + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.green; Layout.preferredWidth: 35; horizontalAlignment: Text.AlignRight }
            }

            // RAM
            RowLayout {
                spacing: 12
                Text { text: "󰍛"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.mauve; Layout.preferredWidth: 20; horizontalAlignment: Text.AlignHCenter }
                Text { text: "RAM"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.subtext; Layout.preferredWidth: 35 }
                Rectangle {
                    Layout.fillWidth: true; height: 8; radius: 4; color: Colors.surface0
                    Rectangle {
                        width: parent.width * (SysInfoService.ramUsage / 100)
                        height: parent.height; radius: parent.radius; color: Colors.mauve
                        Behavior on width { NumberAnimation { duration: Appearance.anim.cpu.dur; easing.type: Easing.OutCubic } }
                    }
                }
                Text { text: SysInfoService.ramUsage + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.mauve; Layout.preferredWidth: 35; horizontalAlignment: Text.AlignRight }
            }
        }
    }
}
