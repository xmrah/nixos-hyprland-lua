import QtQuick
import QtQuick.Layouts
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

    implicitWidth:  220
    implicitHeight: col.implicitHeight + 24

    Rectangle {
        anchors.fill: parent
        radius:       Appearance.size.radius + 2
        color:        Qt.rgba(0.094, 0.094, 0.137, 0.92)
        border.color: Qt.rgba(1, 1, 1, 0.10)
        border.width: 1
    }

    ColumnLayout {
        id: col
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
        spacing: 10

        // CPU
        RowLayout {
            spacing: 8
            Text {
                text: "󰻠"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                color: SysInfoService.cpuColor
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
            Text {
                text: "CPU"; font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12; color: "#a6adc8"
                Layout.minimumWidth: 30
            }
            Rectangle {
                Layout.fillWidth: true; height: 8; radius: 4
                color: Qt.rgba(1,1,1,0.08)
                Rectangle {
                    width: parent.width * (SysInfoService.cpuUsage / 100)
                    height: parent.height; radius: parent.radius
                    color: SysInfoService.cpuColor
                    Behavior on width { NumberAnimation { duration: Appearance.anim.cpu.dur } }
                    Behavior on color { ColorAnimation  { duration: Appearance.anim.cpu.dur } }
                }
            }
            Text {
                text: SysInfoService.cpuUsage + "%"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold
                color: SysInfoService.cpuColor; Layout.minimumWidth: 34
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
        }

        // GPU
        RowLayout {
            spacing: 8
            Text {
                text: "󰾲"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                color: SysInfoService.gpuColor
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
            Text {
                text: "GPU"; font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12; color: "#a6adc8"
                Layout.minimumWidth: 30
            }
            Rectangle {
                Layout.fillWidth: true; height: 8; radius: 4
                color: Qt.rgba(1,1,1,0.08)
                Rectangle {
                    width: parent.width * (SysInfoService.gpuUsage / 100)
                    height: parent.height; radius: parent.radius
                    color: SysInfoService.gpuColor
                    Behavior on width { NumberAnimation { duration: Appearance.anim.cpu.dur } }
                    Behavior on color { ColorAnimation  { duration: Appearance.anim.cpu.dur } }
                }
            }
            Text {
                text: SysInfoService.gpuUsage + "%"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold
                color: SysInfoService.gpuColor; Layout.minimumWidth: 34
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
        }

        // RAM
        RowLayout {
            spacing: 8
            Text {
                text: "󰍛"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                color: SysInfoService.ramColor
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
            Text {
                text: "RAM"; font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12; color: "#a6adc8"
                Layout.minimumWidth: 30
            }
            Rectangle {
                Layout.fillWidth: true; height: 8; radius: 4
                color: Qt.rgba(1,1,1,0.08)
                Rectangle {
                    width: parent.width * (SysInfoService.ramUsage / 100)
                    height: parent.height; radius: parent.radius
                    color: SysInfoService.ramColor
                    Behavior on width { NumberAnimation { duration: Appearance.anim.cpu.dur } }
                    Behavior on color { ColorAnimation  { duration: Appearance.anim.cpu.dur } }
                }
            }
            Text {
                text: SysInfoService.ramUsage + "%"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold
                color: SysInfoService.ramColor; Layout.minimumWidth: 34
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
        }
    }
}
