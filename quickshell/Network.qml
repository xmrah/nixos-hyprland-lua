// Sovereign Network — WiFi / Ethernet durum göstergesi
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property string ssid:      "..."
    property bool   connected: false

    implicitHeight: 44
    implicitWidth:  netRow.implicitWidth + 24
    radius:         14
    color:          Colors.glass
    border.color:   connected
        ? Qt.rgba(0.651, 0.890, 0.631, 0.18)
        : Qt.rgba(0.953, 0.545, 0.659, 0.20)
    border.width: 1

    Behavior on border.color { ColorAnimation { duration: 300 } }

    Row {
        id: netRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text:           root.connected ? "󰤨" : "󰤮"
            font.pixelSize: 13
            color:          root.connected ? Colors.green : Colors.red
            Behavior on color { ColorAnimation { duration: 300 } }
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text:        root.ssid
            font.pixelSize: 12
            font.weight:    Font.DemiBold
            color:          root.connected ? Colors.green : Colors.red
            Behavior on color { ColorAnimation { duration: 300 } }
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
                root.ssid      = s.length > 0 ? s : "Bağlı Değil"
            }
        }
    }

    Process {
        id: nmEditor
        command: ["nm-connection-editor"]
        running: false
    }

    Timer {
        interval:         10000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: if (!netProc.running) netProc.running = true
    }

    TapHandler { onTapped: nmEditor.running = true }
}
