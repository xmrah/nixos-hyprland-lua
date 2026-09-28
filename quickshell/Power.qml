import QtQuick
import Quickshell

// ═══════════════════════════════════════════════════════════════════
// Sovereign Power Button — Bar widget, PowerOverlay'ı açar
// ═══════════════════════════════════════════════════════════════════
Rectangle {
    id: root
    implicitHeight: Appearance.size.widgetH
    implicitWidth:  48
    radius:         Appearance.size.radius
    color: hov.hovered
        ? Qt.rgba(0.953, 0.545, 0.659, 0.18)
        : Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color: hov.hovered
        ? Qt.rgba(0.953, 0.545, 0.659, 0.60)
        : Qt.rgba(0.953, 0.545, 0.659, 0.22)
    border.width: 1
    Behavior on color        { ColorAnimation { duration: Appearance.anim.fast.dur } }
    Behavior on border.color { ColorAnimation { duration: Appearance.anim.fast.dur } }

    Text {
        anchors.centerIn: parent
        text:           "󰐥"
        font.family:    "JetBrainsMono Nerd Font"
        font.pixelSize: 18
        color:          "#f38ba8"
    }

    HoverHandler { id: hov }
    TapHandler   { onTapped: GlobalStates.powerMenuOpen = true }
}
