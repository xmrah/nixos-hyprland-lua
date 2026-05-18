import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    implicitHeight: 30
    implicitWidth:  48
    radius:         12
    color: hov.containsMouse
        ? Qt.rgba(0.953, 0.545, 0.659, 0.18)
        : Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color: hov.containsMouse
        ? Qt.rgba(0.953, 0.545, 0.659, 0.60)
        : Qt.rgba(0.953, 0.545, 0.659, 0.22)
    border.width: 1
    Behavior on color        { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text:           "󰐥"
        font.family:    "JetBrainsMono Nerd Font"
        font.pixelSize: 18
        color:          "#f38ba8"
    }

    Process { id: wlogout; command: ["wlogout"]; running: false }
    HoverHandler { id: hov }
    TapHandler   { onTapped: wlogout.running = true }
}
