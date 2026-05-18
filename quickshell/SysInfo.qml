// Sovereign SysInfo — CPU + RAM birleşik pill
import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    property int cpuUsage: 0
    property int ramUsage: 0

    implicitHeight: 44
    implicitWidth:  infoRow.implicitWidth + 24
    radius:         14
    color:          Colors.glass
    border.color:   Colors.glassBorder
    border.width:   1

    Row {
        id: infoRow
        anchors.centerIn: parent
        spacing: 10

        // CPU
        Row {
            spacing: 5
            Text {
                text:           "  "
                font.pixelSize: 12
                color:          Colors.teal
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text:        root.cpuUsage + "%"
                font.pixelSize: 12
                font.weight:    Font.DemiBold
                color: root.cpuUsage > 90 ? Colors.red
                     : root.cpuUsage > 70 ? Colors.yellow
                     : Colors.teal
                Behavior on color { ColorAnimation { duration: 300 } }
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Ayırıcı çizgi
        Rectangle {
            width:  1
            height: 18
            color:  Qt.rgba(1.0, 1.0, 1.0, 0.10)
            anchors.verticalCenter: parent.verticalCenter
        }

        // RAM
        Row {
            spacing: 5
            Text {
                text:           "  "
                font.pixelSize: 12
                color:          Colors.mauve
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text:        root.ramUsage + "%"
                font.pixelSize: 12
                font.weight:    Font.DemiBold
                color: root.ramUsage > 90 ? Colors.red
                     : root.ramUsage > 75 ? Colors.yellow
                     : Colors.mauve
                Behavior on color { ColorAnimation { duration: 300 } }
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // CPU kullanımı — top ile anlık ölçüm
    Process {
        id: cpuProc
        command: ["sh", "-c", "top -bn1 | awk '/^%Cpu/{printf \"%d\", $2+$4}'"]
        running: false
        stdout: SplitParser {
            onRead: data => root.cpuUsage = parseInt(data) || 0
        }
    }

    // RAM kullanımı — /proc/meminfo'dan
    Process {
        id: ramProc
        command: ["sh", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print int((t-a)/t*100)}' /proc/meminfo"]
        running: false
        stdout: SplitParser {
            onRead: data => root.ramUsage = parseInt(data) || 0
        }
    }

    Timer {
        interval:         2000
        running:          true
        repeat:           true
        triggeredOnStart: true
        onTriggered: {
            if (!cpuProc.running) cpuProc.running = true
            if (!ramProc.running) ramProc.running = true
        }
    }
}
