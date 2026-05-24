import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    property int  volume: 0
    property bool muted:  false

    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 20
    radius:         Appearance.size.radius
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(0.976, 0.886, 0.686, muted ? 0.08 : 0.18)
    border.width:   1
    Behavior on border.color { ColorAnimation { duration: Appearance.anim.fast.dur } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.muted       ? "󰝟"
                : root.volume < 30 ? "󰕿"
                : root.volume < 70 ? "󰖀"
                :                    "󰕾"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            color:          root.muted ? "#45475a" : "#f9e2af"
            Behavior on color { ColorAnimation { duration: Appearance.anim.fast.dur } }
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text:           root.volume + "%"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.weight:    Font.DemiBold
            color:          root.muted ? "#6c7086" : "#f9e2af"
            Behavior on color { ColorAnimation { duration: Appearance.anim.fast.dur } }
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Process {
        id: volProc
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
    Process { id: volUp;   command: ["sh", "-c", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"]; running: false; onExited: volProc.running = true }
    Process { id: volDown; command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"];      running: false; onExited: volProc.running = true }
    Process { id: pavuctl; command: ["pavucontrol"]; running: false }

    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!volProc.running) volProc.running = true }
    TapHandler { onTapped: pavuctl.running = true }
    MouseArea {
        anchors.fill:        parent
        acceptedButtons:     Qt.NoButton
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0 && !volUp.running)   volUp.running   = true
            else if (!volDown.running)                        volDown.running = true
        }
    }
}
