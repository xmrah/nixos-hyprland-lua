import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    property string ssid:      ""
    property bool   connected: false

    implicitHeight: 30
    implicitWidth:  row.implicitWidth + 20
    radius:         12
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   connected
        ? Qt.rgba(0.651, 0.890, 0.631, 0.20)
        : Qt.rgba(0.953, 0.545, 0.659, 0.20)
    border.width: 1
    Behavior on border.color { ColorAnimation { duration: 300 } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            text:           root.connected ? "󰤨" : "󰤮"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 17
            color:          root.connected ? "#a6e3a1" : "#f38ba8"
            Behavior on color { ColorAnimation { duration: 300 } }
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            visible:        root.connected && root.ssid !== ""
            text:           root.ssid
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            color:          "#a6e3a1"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Process {
        id: netProc
        command: ["sh", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 | head -1"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim()
                root.connected = s.length > 0
                root.ssid      = s
            }
        }
    }
    Process { id: nmEd; command: ["nm-connection-editor"]; running: false }

    Timer { interval: 15000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!netProc.running) netProc.running = true }
    TapHandler { onTapped: nmEd.running = true }
}
