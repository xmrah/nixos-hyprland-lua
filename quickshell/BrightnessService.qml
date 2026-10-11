pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

// Parlaklık servisi — ddcutil ve brightnessctl dinamik uyumluluğu
// Brightness.qml sadece bu singleton'ı gözlemler
// NOT: DDC/CI yavaş (50-200ms/komut), brightnessctl anında döner
Singleton {
    id: root

    property int brightness: 0

    // ── Komutlar ──────────────────────────────────────────────────────
    Process {
        id: getProc
        command: ["sh", "-c", "if command -v brightnessctl >/dev/null 2>&1 && brightnessctl -m >/dev/null 2>&1; then brightnessctl -m | awk -F, '{gsub(/%/,\"\",$4); print $4; exit}'; elif command -v ddcutil >/dev/null 2>&1; then ddcutil getvcp 10 2>/dev/null | grep -oP 'current value =\\s*\\K[0-9]+' | head -n1; fi"]
        running: false
        stdout: SplitParser {
            onRead: data => root.brightness = parseInt(data) || 0
        }
    }

    // onExited: refresh() — komutlar sıralı çalışmalı, refresh tetikler
    Process {
        id: brightUp
        command: ["sh", "-c", "if command -v brightnessctl >/dev/null 2>&1 && brightnessctl -m >/dev/null 2>&1; then brightnessctl set +5%; elif command -v ddcutil >/dev/null 2>&1; then ddcutil setvcp 10 + 5 2>/dev/null; fi"]
        running: false
        onExited: refresh()
    }
    Process {
        id: brightDown
        command: ["sh", "-c", "if command -v brightnessctl >/dev/null 2>&1 && brightnessctl -m >/dev/null 2>&1; then brightnessctl set 5%-; elif command -v ddcutil >/dev/null 2>&1; then ddcutil setvcp 10 - 5 2>/dev/null; fi"]
        running: false
        onExited: refresh()
    }

    // ── 60 saniyede bir otomatik güncelle ─────────────
    Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: refresh() }

    // ── Public API ────────────────────────────────────────────────────
    function refresh()        { if (!getProc.running)   getProc.running   = true }
    function increase()       { if (!brightUp.running)  brightUp.running  = true }
    function decrease()       { if (!brightDown.running) brightDown.running = true }
}
