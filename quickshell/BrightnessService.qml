pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Parlaklık servisi — tüm ddcutil çağrıları tek yerde
// Brightness.qml sadece bu singleton'ı gözlemler
// NOT: DDC/CI yavaş (50-200ms/komut) — agresif polling/repeating yapma
Singleton {
    id: root

    property int brightness: 0

    // ── Komutlar ──────────────────────────────────────────────────────
    Process {
        id: getProc
        command: ["sh", "-c", "ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\\s*\\K[0-9]+'"]
        running: false
        stdout: SplitParser {
            onRead: data => root.brightness = parseInt(data) || 0
        }
    }

    // onExited: refresh() — DDC/CI komutları sıralı çalışmalı, refresh tetikler
    Process { id: brightUp;   command: ["sh", "-c", "ddcutil setvcp 10 + 5"]; running: false; onExited: refresh() }
    Process { id: brightDown; command: ["sh", "-c", "ddcutil setvcp 10 - 5"]; running: false; onExited: refresh() }

    // ── 10 saniyede bir otomatik güncelle (DDC/CI yavaş) ─────────────
    Timer { interval: 10000; running: true; repeat: true; triggeredOnStart: true; onTriggered: refresh() }

    // ── Public API ────────────────────────────────────────────────────
    function refresh()        { if (!getProc.running)   getProc.running   = true }
    function increase()       { if (!brightUp.running)  brightUp.running  = true }
    function decrease()       { if (!brightDown.running) brightDown.running = true }
}
