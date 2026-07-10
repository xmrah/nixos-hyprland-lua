import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

WlrLayershell {
    id: root
    required property var screen
    screen: root.screen

    layer:         WlrLayer.Top
    namespace:     "sovereign-bar"
    exclusiveZone: Appearance.size.barH + Appearance.size.marginTop

    anchors { top: true; left: true; right: true }

    implicitHeight: Appearance.size.barH + Appearance.size.marginTop
    color: "transparent"

    RowLayout {
        anchors {
            fill:        parent
            topMargin:   Appearance.size.marginTop
            leftMargin:  Appearance.size.marginSide
            rightMargin: Appearance.size.marginSide
        }
        spacing: 5

        Workspaces    { Layout.alignment: Qt.AlignVCenter }
        ActiveWindow  { id: activeWidget; Layout.alignment: Qt.AlignVCenter; visible: activeWidget.hasContent }
        Item          { Layout.fillWidth: true }
        Clock         { Layout.alignment: Qt.AlignVCenter }
        Item          { Layout.fillWidth: true }
        Tray          { Layout.alignment: Qt.AlignVCenter }
        Notifications { Layout.alignment: Qt.AlignVCenter }
        DashboardToggle { Layout.alignment: Qt.AlignVCenter }
    }
}
