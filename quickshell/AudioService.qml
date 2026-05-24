pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Ses servisi — tüm wpctl çağrıları tek yerde
// Volume.qml sadece bu singleton'ı gözlemler
Singleton {
    id: root

    property int  volume: 0
    property bool muted:  false

    // ── Komutlar ──────────────────────────────────────────────────────
    Process {
        id: volProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                root.muted  = data.includes("[MUTED]")
                const m = data.match(/[\d.]+/)
                if (m) root.volume = Math.round(parseFloat(m[0]) * 100)
            }
        }
    }

    Process { id: volUp;   command: ["sh", "-c", "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+"]; running: false; onExited: refresh() }
    Process { id: volDown; command: ["sh", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"];      running: false; onExited: refresh() }
    Process { id: muteToggle; command: ["sh", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]; running: false; onExited: refresh() }
    Process { id: pavuctl; command: ["pavucontrol"]; running: false }

    // ── 3 saniyede bir otomatik güncelle ──────────────────────────────
    Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: refresh() }

    // ── Public API ────────────────────────────────────────────────────
    function refresh()        { if (!volProc.running)    volProc.running    = true }
    function raiseVolume()    { if (!volUp.running)      volUp.running      = true }
    function lowerVolume()    { if (!volDown.running)    volDown.running    = true }
    function toggleMute()     { if (!muteToggle.running) muteToggle.running = true }
    function openMixer()      { if (!pavuctl.running)    pavuctl.running    = true }
}
