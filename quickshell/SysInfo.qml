import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    property int cpuUsage: 0
    property int ramUsage: 0

    implicitHeight: 30
    implicitWidth:  row.implicitWidth + 20
    radius:         10
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(1, 1, 1, 0.07)
    border.width:   1

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 10

        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "󰻠"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                color: "#89dceb"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.cpuUsage + "%"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.weight: Font.DemiBold
                color: root.cpuUsage > 90 ? "#f38ba8" : root.cpuUsage > 70 ? "#f9e2af" : "#89dceb"
                Behavior on color { ColorAnimation { duration: 300 } }
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle { width: 1; height: 16; color: Qt.rgba(1,1,1,0.10); anchors.verticalCenter: parent.verticalCenter }

        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "󰍛"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15
                color: "#cba6f7"
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: root.ramUsage + "%"
                font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 13; font.weight: Font.DemiBold
                color: root.ramUsage > 90 ? "#f38ba8" : root.ramUsage > 75 ? "#f9e2af" : "#cba6f7"
                Behavior on color { ColorAnimation { duration: 300 } }
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "top -bn1 | awk '/^%Cpu/{printf \"%d\", $2+$4}'"]
        running: false
        stdout: SplitParser { onRead: data => root.cpuUsage = parseInt(data) || 0 }
    }
    Process {
        id: ramProc
        command: ["sh", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print int((t-a)/t*100)}' /proc/meminfo"]
        running: false
        stdout: SplitParser { onRead: data => root.ramUsage = parseInt(data) || 0 }
    }

    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (!cpuProc.running) cpuProc.running = true
            if (!ramProc.running) ramProc.running = true
        }
    }
}
