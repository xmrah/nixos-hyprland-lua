import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    property int brightness: 0

    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 20
    radius:         Appearance.size.radius
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(0.980, 0.898, 0.686, 0.18)
    border.width:   1
    Behavior on border.color { ColorAnimation { duration: Appearance.anim.fast.dur } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: root.brightness < 30 ? "󰃞"
                : root.brightness < 70 ? "󰃟"
                :                        "󰃠"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            color:          "#f9e2af"
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text:           root.brightness + "%"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            font.weight:    Font.DemiBold
            color:          "#f9e2af"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Process {
        id: getProc
        command: ["sh", "-c", "ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\\s*\\K[0-9]+'"]
        running: false
        stdout: SplitParser {
            onRead: data => root.brightness = parseInt(data) || 0
        }
    }

    Process { id: brightUp;   command: ["sh", "-c", "ddcutil setvcp 10 + 5"]; running: false; onExited: getProc.running = true }
    Process { id: brightDown; command: ["sh", "-c", "ddcutil setvcp 10 - 5"]; running: false; onExited: getProc.running = true }

    // DDC/CI yavaş — 10 saniyede bir güncelle
    Timer { interval: 10000; running: true; repeat: true; triggeredOnStart: true; onTriggered: if (!getProc.running) getProc.running = true }

    MouseArea {
        anchors.fill:    parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0 && !brightUp.running)   brightUp.running   = true
            else if (!brightDown.running)                        brightDown.running = true
        }
    }
}
