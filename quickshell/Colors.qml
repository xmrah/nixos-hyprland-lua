pragma Singleton
import Quickshell
import QtQuick

// Sovereign Color Palette
// Catppuccin Mocha + Material You (colors.lua ile senkron)
Singleton {
    // ── Catppuccin Mocha Base ──────────────────────────────────────────
    readonly property color base:     "#1e1e2e"
    readonly property color mantle:   "#181825"
    readonly property color crust:    "#11111b"
    readonly property color surface0: "#313244"
    readonly property color surface1: "#45475a"
    readonly property color overlay0: "#6c7086"
    readonly property color subtext:  "#a6adc8"
    readonly property color text:     "#cdd6f4"

    // ── Material You Aksan Renkleri ────────────────────────────────────
    readonly property color cyan:   "#7dcfff"   // aktif pencere / workspace
    readonly property color purple: "#c27afa"   // hover
    readonly property color peach:  "#fab387"   // saat
    readonly property color green:  "#a6e3a1"   // ağ / medya
    readonly property color red:    "#f38ba8"   // güç / kritik
    readonly property color yellow: "#f9e2af"   // ses / uyarı
    readonly property color teal:   "#89dceb"   // CPU
    readonly property color mauve:  "#cba6f7"   // RAM / medya
    readonly property color blue:   "#89b4fa"   // genel bilgi

    // ── Glassmorphism Yüzeyler ─────────────────────────────────────────
    readonly property color glass:       Qt.rgba(0.118, 0.118, 0.180, 0.72)
    readonly property color glassHover:  Qt.rgba(0.192, 0.196, 0.259, 0.85)
    readonly property color glassBorder: Qt.rgba(1.0,   1.0,   1.0,   0.07)
}
