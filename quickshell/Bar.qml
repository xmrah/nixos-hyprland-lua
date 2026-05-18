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
    exclusiveZone: barH + marginTop

    anchors { top: true; left: true; right: true }

    readonly property int barH:       36
    readonly property int marginTop:  3
    readonly property int marginSide: 12

    implicitHeight: barH + marginTop
    color: "transparent"

    RowLayout {
        anchors {
            fill:        parent
            topMargin:   root.marginTop
            leftMargin:  root.marginSide
            rightMargin: root.marginSide
        }
        spacing: 5

        Workspaces { Layout.alignment: Qt.AlignVCenter }
        Item       { Layout.fillWidth: true }
        Clock      { Layout.alignment: Qt.AlignVCenter }
        Item       { Layout.fillWidth: true }
        SysInfo    { Layout.alignment: Qt.AlignVCenter }
        Volume     { Layout.alignment: Qt.AlignVCenter }
        Network    { Layout.alignment: Qt.AlignVCenter }
        Tray       { Layout.alignment: Qt.AlignVCenter }
        Power      { Layout.alignment: Qt.AlignVCenter }
    }
}
