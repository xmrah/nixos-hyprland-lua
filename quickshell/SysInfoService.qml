pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: svc

    property int cpuUsage: 0
    property int gpuUsage: 0
    property int ramUsage: 0

    property var cpuHistory: []
    property var gpuHistory: []
    property var ramHistory: []

    readonly property color cpuColor: cpuUsage > 90 ? "#f38ba8" : cpuUsage > 70 ? "#f9e2af" : "#89dceb"
    readonly property color gpuColor: gpuUsage > 90 ? "#f38ba8" : gpuUsage > 70 ? "#f9e2af" : "#a6e3a1"
    readonly property color ramColor: ramUsage > 90 ? "#f38ba8" : ramUsage > 75 ? "#f9e2af" : "#cba6f7"

    property var _cpuProc: Process {
        command: ["sh", "-c", "top -bn1 | awk '/^%Cpu/{printf \"%d\", $2+$4}'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const v = parseInt(data) || 0
                svc.cpuUsage   = v
                svc.cpuHistory = svc.cpuHistory.concat([v]).slice(-20)
            }
        }
    }

    property var _gpuProc: Process {
        command: ["sh", "-c", "cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null || echo 0"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const v = parseInt(data) || 0
                svc.gpuUsage   = v
                svc.gpuHistory = svc.gpuHistory.concat([v]).slice(-20)
            }
        }
    }

    property var _ramProc: Process {
        command: ["sh", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{print int((t-a)/t*100)}' /proc/meminfo"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const v = parseInt(data) || 0
                svc.ramUsage   = v
                svc.ramHistory = svc.ramHistory.concat([v]).slice(-20)
            }
        }
    }

    property var _timer: Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (!svc._cpuProc.running) svc._cpuProc.running = true
            if (!svc._gpuProc.running) svc._gpuProc.running = true
            if (!svc._ramProc.running) svc._ramProc.running = true
        }
    }
}
