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

        Workspaces { Layout.alignment: Qt.AlignVCenter }
        Item       { Layout.fillWidth: true }
        Clock      { Layout.alignment: Qt.AlignVCenter }
        Item       { Layout.fillWidth: true }
        SysInfo    { Layout.alignment: Qt.AlignVCenter }
        Brightness { Layout.alignment: Qt.AlignVCenter }
        Volume     { Layout.alignment: Qt.AlignVCenter }
        Network    { Layout.alignment: Qt.AlignVCenter }
        Tray       { Layout.alignment: Qt.AlignVCenter }
        Power      { Layout.alignment: Qt.AlignVCenter }
    }
}
