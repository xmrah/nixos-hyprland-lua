pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: svc

    property int cpuUsage: 0
    property int gpuUsage: 0
    property int ramUsage: 0
    property int vramUsage: 0

    property string ramText: "0.0 / 0.0 GB"
    property string vramText: "0.0 / 0.0 GB"

    property var topProcesses: []

    property var _cpuProc: Process {
        command: ["sh", "-c", "top -bn1 | awk '/^%Cpu/{printf \"%d\", $2+$4}'"]
        running: false
        stdout: SplitParser {
            onRead: data => { svc.cpuUsage = parseInt(data) || 0 }
        }
    }

    property var _gpuProc: Process {
        command: ["sh", "-c", "cat /sys/class/drm/card1/device/gpu_busy_percent 2>/dev/null || echo 0"]
        running: false
        stdout: SplitParser {
            onRead: data => { svc.gpuUsage = parseInt(data) || 0 }
        }
    }

    property var _vramProc: Process {
        command: ["sh", "-c", "u=$(cat /sys/class/drm/card1/device/mem_info_vram_used 2>/dev/null || echo 0); t=$(cat /sys/class/drm/card1/device/mem_info_vram_total 2>/dev/null || echo 1073741824); awk -v u=$u -v t=$t 'BEGIN { printf \"%d|%.1f / %.1f GB\\n\", (u/t)*100, u/1073741824, t/1073741824 }'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split("|")
                if(parts.length === 2) {
                    svc.vramUsage = parseInt(parts[0]) || 0
                    svc.vramText = parts[1].trim()
                }
            }
        }
    }

    property var _ramProc: Process {
        command: ["sh", "-c", "free -m | awk '/Mem:/{printf \"%d|%.1f / %.1f GB\", $3/$2*100, $3/1024, $2/1024}'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split("|")
                if(parts.length === 2) {
                    svc.ramUsage = parseInt(parts[0]) || 0
                    svc.ramText = parts[1].trim()
                }
            }
        }
    }

    property var _psProc: Process {
        command: ["sh", "-c", "ps axco comm,pmem --sort=-pmem | head -n 6 | tail -n 5 | awk '{print $1\"|\"$2\"%\"}'"]
        running: false
        property var tempArr: []
        stdout: SplitParser {
            onRead: data => {
                let p = data.trim().split("|")
                if(p.length === 2) _psProc.tempArr.push({name: p[0], mem: p[1]})
            }
        }
        onExited: {
            svc.topProcesses = _psProc.tempArr
            _psProc.tempArr = []
        }
    }

    property var _timer: Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            if (!svc._cpuProc.running) svc._cpuProc.running = true
            if (!svc._gpuProc.running) svc._gpuProc.running = true
            if (!svc._ramProc.running) svc._ramProc.running = true
            if (!svc._vramProc.running) svc._vramProc.running = true
            if (!svc._psProc.running) svc._psProc.running = true
        }
    }
}
