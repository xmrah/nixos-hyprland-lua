import QtQuick
import Quickshell
import Quickshell.Wayland

// ═══════════════════════════════════════════════════════════════════
// Sovereign Active Window — Wayland Native Toplevel (Event-Driven)
// 0 Process, 0 Fork, 0ms Gecikme. Tıkla → aktif pencereyi kapat.
// ═══════════════════════════════════════════════════════════════════
Rectangle {
    id: root

    readonly property string windowTitle: ToplevelManager.activeToplevel?.title ?? ""
    readonly property bool   hasContent:  windowTitle.length > 0

    visible:        hasContent
    implicitHeight: Appearance.size.widgetH
    implicitWidth:  titleText.implicitWidth + 20
    radius:         Appearance.size.radiusSm
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(0.537, 0.706, 0.980, 0.18)
    border.width:   1

    Text {
        id: titleText
        anchors.centerIn: parent
        property string full: root.windowTitle
        text:           full.length > 40 ? full.substring(0, 40) + "\u2026" : full
        font.family:    "JetBrainsMono Nerd Font"
        font.pixelSize: Appearance.size.textSize
        font.weight:    Font.DemiBold
        color:          "#89b4fa"
    }

    TapHandler {
        onTapped: {
            if (ToplevelManager.activeToplevel) {
                ToplevelManager.activeToplevel.close()
            }
        }
    }
}
