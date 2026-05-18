// Sovereign Volume — PipeWire/WirePlumber ses kontrolü
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property int  volume: 0
    property bool muted:  false

    implicitHeight: 44
    implicitWidth:  volRow.implicitWidth + 24
    radius:         14
    color:          Colors.glass
    border.color:   Qt.rgba(0.976, 0.886, 0.686, 0.18)
    border.width:   1

    Row {
        id: volRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.muted        ? "󰝟"
                : root.volume < 30  ? "󰕿"
                : root.volume < 70  ? "󰖀"
                :                     "󰕾"
            font.pixelSize: 13
            color:          root.muted ? Colors.surface1 : Colors.yellow
            Behavior on color { ColorAnimation { duration: 150 } }
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text:        root.muted ? "Sessiz" : root.volume + "%"
            font.pixelSize: 12
            font.weight:    Font.DemiBold
            color:          root.muted ? Colors.overlay0 : Colors.yellow
            Behavior on color { ColorAnimation { duration: 150 } }
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // Ses seviyesi sorgula
    Process {
        id: volRefresh
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                root.muted = data.includes("[MUTED]")
                const m = data.match(/[\d.]+/)
                if (m) root.volume = Math.round(parseFloat(m[0]) * 100)
            }
        }
    }

    // Ses yükselt
    Process {
        id: volUp
        command: ["sh", "-c", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"]
        running: false
        onExited: volRefresh.running = true
    }

    // Ses azalt
    Process {
        id: volDown
        command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"]
        running: false
        onExited: volRefresh.running = true
    }

    // pavucontrol aç
    Process {
        id: pavuLaunch
        command: ["pavucontrol"]
        running: false
    }

    Timer {
        interval:         2000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: if (!volRefresh.running) volRefresh.running = true
    }

    TapHandler   { onTapped: pavuLaunch.running = true }

    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y > 0 && !volUp.running)
                volUp.running = true
            else if (!volDown.running)
                volDown.running = true
        }
    }
}
