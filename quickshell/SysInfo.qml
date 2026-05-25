import QtQuick
import Quickshell

Rectangle {
    id: root

    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 20
    radius:         Appearance.size.radiusSm
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(1, 1, 1, 0.07)
    border.width:   1

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "󰻠"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                color: SysInfoService.cpuColor; anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
            Text {
                text: SysInfoService.cpuUsage + "%"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.weight: Font.DemiBold
                color: SysInfoService.cpuColor; anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
        }

        Rectangle { width: 1; height: 14; color: Qt.rgba(1,1,1,0.10); anchors.verticalCenter: parent.verticalCenter }

        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "󰾲"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                color: SysInfoService.gpuColor; anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
            Text {
                text: SysInfoService.gpuUsage + "%"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.weight: Font.DemiBold
                color: SysInfoService.gpuColor; anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
        }

        Rectangle { width: 1; height: 14; color: Qt.rgba(1,1,1,0.10); anchors.verticalCenter: parent.verticalCenter }

        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "󰍛"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                color: SysInfoService.ramColor; anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
            Text {
                text: SysInfoService.ramUsage + "%"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.weight: Font.DemiBold
                color: SysInfoService.ramColor; anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: Appearance.anim.cpu.dur } }
            }
        }
    }

    TapHandler {
        onTapped: GlobalStates.sysInfoOpen = !GlobalStates.sysInfoOpen
    }
}
