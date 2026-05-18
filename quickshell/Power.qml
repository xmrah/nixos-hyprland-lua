// Sovereign Power — Oturum kapatma butonu
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    implicitHeight: 44
    implicitWidth:  46
    radius:         14
    color: hovered.containsMouse
        ? Qt.rgba(0.953, 0.545, 0.659, 0.20)
        : Colors.glass
    border.color: hovered.containsMouse
        ? Qt.rgba(0.953, 0.545, 0.659, 0.55)
        : Qt.rgba(0.953, 0.545, 0.659, 0.20)
    border.width: 1

    Behavior on color        { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text:           "⏻"
        font.pixelSize: 16
        color:          Colors.red
    }

    Process {
        id: wlogoutProc
        command: ["wlogout"]
        running: false
    }

    HoverHandler { id: hovered }
    TapHandler   { onTapped: wlogoutProc.running = true }
}
