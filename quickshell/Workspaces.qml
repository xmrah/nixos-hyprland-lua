// Sovereign Workspaces — Hyprland IPC ile workspace göstergesi
import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root

    implicitHeight: 44
    implicitWidth:  wsRow.implicitWidth + 16
    radius:         14
    color:          Colors.glass
    border.color:   Colors.glassBorder
    border.width:   1

    Row {
        id: wsRow
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: Hyprland.workspaces

            delegate: Rectangle {
                id: btn
                required property HyprlandWorkspace modelData

                readonly property bool isActive:    modelData.id === (Hyprland.focusedMonitor?.activeWorkspace?.id ?? -1)
                readonly property bool hasWindows:  modelData.windows > 0

                implicitWidth:  isActive ? 34 : 28
                implicitHeight: 34
                radius: 9

                color: isActive
                    ? Qt.rgba(0.490, 0.812, 1.0,  0.18)
                    : hasWindows
                        ? Qt.rgba(1.0,   1.0,   1.0,  0.05)
                        : "transparent"

                Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on color        { ColorAnimation   { duration: 150 } }

                // Workspace ID / icon
                Text {
                    anchors.centerIn: parent
                    text:         btn.modelData.id
                    font.pixelSize: btn.isActive ? 13 : 11
                    font.weight:    btn.isActive ? Font.Bold : Font.Normal
                    color:          btn.isActive ? Colors.cyan : Colors.overlay0

                    Behavior on color          { ColorAnimation  { duration: 150 } }
                    Behavior on font.pixelSize { NumberAnimation { duration: 150 } }
                }

                // Aktif workspace alt çizgisi (cyan)
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom:           parent.bottom
                    anchors.bottomMargin:     4
                    width:  btn.isActive ? 14 : 0
                    height: 2
                    radius: 1
                    color:  Colors.cyan

                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }

                HoverHandler { id: wsHover }

                TapHandler {
                    onTapped: Hyprland.dispatch("workspace " + btn.modelData.id)
                }
            }
        }
    }
}
