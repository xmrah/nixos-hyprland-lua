import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root
    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 14
    radius:         Appearance.size.radiusSm
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(1, 1, 1, 0.07)
    border.width:   1

    readonly property int activeId: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1

    function isOccupied(id) {
        for (let i = 0; i < Hyprland.workspaces.length; i++) {
            if (Hyprland.workspaces[i].id === id && Hyprland.workspaces[i].windows > 0)
                return true
        }
        return false
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: 9

            delegate: Item {
                id: btn
                readonly property int wsId:      modelData + 1
                readonly property bool isActive:  wsId === root.activeId
                readonly property bool occupied:  root.isOccupied(wsId)

                implicitWidth:  isActive ? 24 : 8
                implicitHeight: 30

                Behavior on implicitWidth { NumberAnimation { duration: Appearance.anim.ws.dur; easing.type: Easing.OutCubic } }

                Rectangle {
                    anchors.centerIn: parent
                    width:  btn.isActive ? 24 : (btn.occupied ? 7 : 5)
                    height: btn.isActive ? 20 : (btn.occupied ? 7 : 5)
                    radius: btn.isActive ? 6 : 10

                    color: btn.isActive  ? Qt.rgba(0.490, 0.812, 1.0, 0.22)
                         : btn.occupied  ? Qt.rgba(0.490, 0.812, 1.0, 0.50)
                         :                 Qt.rgba(1, 1, 1, 0.15)

                    border.color: btn.isActive ? Qt.rgba(0.490, 0.812, 1.0, 0.65) : "transparent"
                    border.width: btn.isActive ? 1 : 0

                    Behavior on width        { NumberAnimation { duration: Appearance.anim.ws.dur; easing.type: Easing.OutCubic } }
                    Behavior on height       { NumberAnimation { duration: Appearance.anim.ws.dur; easing.type: Easing.OutCubic } }
                    Behavior on color        { ColorAnimation  { duration: Appearance.anim.fast.dur } }
                    Behavior on border.color { ColorAnimation  { duration: Appearance.anim.fast.dur } }

                    Text {
                        anchors.centerIn: parent
                        visible:          btn.isActive
                        text:             btn.wsId
                        font.family:      "JetBrainsMono Nerd Font"
                        font.pixelSize:   11
                        font.weight:      Font.Bold
                        color:            "#7dcfff"
                    }
                }

                TapHandler { onTapped: Hyprland.dispatch("workspace " + btn.wsId) }
            }
        }
    }
}
