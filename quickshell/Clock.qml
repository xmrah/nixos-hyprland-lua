import QtQuick
import Quickshell

Rectangle {
    id: root
    property bool showDate: false

    implicitHeight: 30
    implicitWidth:  label.implicitWidth + 28
    radius:         10
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   hov.containsMouse
        ? Qt.rgba(0.980, 0.702, 0.529, 0.40)
        : Qt.rgba(0.980, 0.702, 0.529, 0.15)
    border.width: 1
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Text {
        id: label
        anchors.centerIn: parent
        font.family:      "JetBrainsMono Nerd Font"
        font.pixelSize:   15
        font.weight:      Font.Bold
        font.letterSpacing: 0.5
        color:            "#fab387"
    }

    Timer {
        interval: 10000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: label.text = root.showDate
            ? Qt.formatDateTime(new Date(), "ddd d MMM")
            : Qt.formatDateTime(new Date(), "hh:mm")
    }

    HoverHandler { id: hov }
    TapHandler {
        onTapped: {
            root.showDate = !root.showDate
            label.text = root.showDate
                ? Qt.formatDateTime(new Date(), "ddd d MMM")
                : Qt.formatDateTime(new Date(), "hh:mm")
        }
    }
}
