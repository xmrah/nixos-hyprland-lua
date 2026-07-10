import QtQuick
import Quickshell

Rectangle {
    id: root
    implicitHeight: Appearance.size.widgetH
    implicitWidth:  Appearance.size.widgetH + 10
    radius:         Appearance.size.radiusSm
    color:          GlobalStates.dashboardOpen ? Colors.surface1 : Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   GlobalStates.dashboardOpen ? Colors.blue : Qt.rgba(1, 1, 1, 0.07)
    border.width:   1
    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: "󰍜"
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 18
        color: GlobalStates.dashboardOpen ? Colors.blue : Colors.text
    }

    TapHandler {
        onTapped: GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen
    }
}
