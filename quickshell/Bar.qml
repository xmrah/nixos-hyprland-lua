import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// ═══════════════════════════════════════════════════════════════════
// Sovereign Bar — Sol / Orta / Sağ dengeli profesyonel bar
// Sol: Workspaces + ActiveWindow
// Orta: Clock
// Sağ: Tray + Notifications + QuickSettings Capsule + Power
// ═══════════════════════════════════════════════════════════════════
WlrLayershell {
    id: root

    layer:         WlrLayer.Top
    namespace:     "sovereign-bar"
    exclusiveZone: Appearance.size.barH + Appearance.size.marginTop

    anchors { top: true; left: true; right: true }

    implicitHeight: Appearance.size.barH + Appearance.size.marginTop
    color: "transparent"

    visible: GlobalStates.barVisible

    RowLayout {
        anchors {
            fill:        parent
            topMargin:   Appearance.size.marginTop
            leftMargin:  Appearance.size.marginSide
            rightMargin: Appearance.size.marginSide
        }
        spacing: 6

        // ═══════════════════════════════════════════
        // SOL BÖLGE — Workspace + Active Window
        // ═══════════════════════════════════════════
        Workspaces   { Layout.alignment: Qt.AlignVCenter }
        ActiveWindow {
            id: activeWidget
            Layout.alignment: Qt.AlignVCenter
            visible: activeWidget.hasContent
        }

        // Spacer
        Item { Layout.fillWidth: true }

        // ═══════════════════════════════════════════
        // ORTA BÖLGE — Clock
        // ═══════════════════════════════════════════
        Clock { Layout.alignment: Qt.AlignVCenter }

        // Spacer
        Item { Layout.fillWidth: true }

        // ═══════════════════════════════════════════
        // SAĞ BÖLGE — Tray → Notif → QuickSettings / Hub Capsule
        // ═══════════════════════════════════════════
        Tray            { Layout.alignment: Qt.AlignVCenter }
        Notifications   { Layout.alignment: Qt.AlignVCenter }
        DashboardToggle { Layout.alignment: Qt.AlignVCenter }
    }
}
