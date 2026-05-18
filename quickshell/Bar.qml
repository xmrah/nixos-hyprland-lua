// Sovereign Bar — Ana Panel
// Ekranın üstüne yapışır, compositor blur ile glassmorphism efekti
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var screen
    screen: root.screen

    WaylandLayerShell.layer:         WaylandLayerShell.Layer.Top
    WaylandLayerShell.namespace:     "sovereign-bar"
    WaylandLayerShell.exclusiveZone: barH + marginTop

    anchors { top: true; left: true; right: true }

    readonly property int barH:       44
    readonly property int marginTop:  10
    readonly property int marginSide: 14

    implicitHeight: barH + marginTop
    color: "transparent"

    RowLayout {
        anchors {
            fill:         parent
            topMargin:    root.marginTop
            leftMargin:   root.marginSide
            rightMargin:  root.marginSide
            bottomMargin: 0
        }
        spacing: 6

        // Sol: Workspace göstergesi
        Workspaces  { Layout.alignment: Qt.AlignVCenter }

        Item { Layout.fillWidth: true }

        // Orta: Saat
        Clock       { Layout.alignment: Qt.AlignVCenter }

        Item { Layout.fillWidth: true }

        // Sağ: Sistem modülleri
        SysInfo     { Layout.alignment: Qt.AlignVCenter }
        Volume      { Layout.alignment: Qt.AlignVCenter }
        Network     { Layout.alignment: Qt.AlignVCenter }
        Tray        { Layout.alignment: Qt.AlignVCenter }
        Power       { Layout.alignment: Qt.AlignVCenter }
    }
}
