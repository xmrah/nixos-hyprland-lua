import QtQuick
import Quickshell

Rectangle {
    id: root
    property bool showDate: false

    implicitHeight: Appearance.size.widgetH
    implicitWidth:  label.implicitWidth + 28
    radius:         Appearance.size.radiusSm
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   hov.hovered
        ? Qt.rgba(0.980, 0.702, 0.529, 0.45)
        : Qt.rgba(0.980, 0.702, 0.529, 0.15)
    border.width: 1
    Behavior on border.color { ColorAnimation { duration: Appearance.anim.fast.dur } }

    Text {
        id: label
        anchors.centerIn: parent
        font.family:      "JetBrainsMono Nerd Font"
        font.pixelSize:   13
        font.weight:      Font.Bold
        font.letterSpacing: 0.5
        color:            "#fab387"
    }

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: label.text = Qt.formatDateTime(new Date(), "hh:mm · ddd d MMM")
    }

    HoverHandler { id: hov }
    TapHandler {
        onTapped: {
            GlobalStates.notificationPanelOpen = !GlobalStates.notificationPanelOpen
            if (GlobalStates.notificationPanelOpen) GlobalStates.dashboardOpen = false
        }
    }
}
