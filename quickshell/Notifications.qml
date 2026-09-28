import QtQuick
import Quickshell

// ═══════════════════════════════════════════════════════════════════
// Sovereign Notifications Bar Widget
// GlobalStates.notificationCount'u gösterir + panel toggle
// ═══════════════════════════════════════════════════════════════════
Rectangle {
    id: root
    readonly property int count: GlobalStates.notificationCount
    readonly property bool hasNotifications: count > 0

    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 16
    radius:         Appearance.size.radius
    color:          hov.hovered
                        ? Qt.rgba(0.651, 0.890, 0.631, 0.12)
                        : Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   hasNotifications
                        ? Qt.rgba(0.651, 0.890, 0.631, 0.35)
                        : hov.hovered
                            ? Qt.rgba(1, 1, 1, 0.12)
                            : Qt.rgba(1, 1, 1, 0.07)
    border.width:   1

    Behavior on color        { ColorAnimation { duration: Appearance.anim.fast.dur } }
    Behavior on border.color { ColorAnimation { duration: Appearance.anim.fast.dur } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text:             root.hasNotifications ? "󰂚" : "󰂜"
            font.family:      "JetBrainsMono Nerd Font"
            font.pixelSize:   Appearance.size.iconSize
            color:            root.hasNotifications ? "#a6e3a1" : "#6c7086"
            Behavior on color { ColorAnimation { duration: Appearance.anim.fast.dur } }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible:        root.hasNotifications
            text:           root.count
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: Appearance.size.textSize
            font.weight:    Font.Bold
            color:          "#a6e3a1"
        }
    }

    HoverHandler { id: hov }
    TapHandler {
        onTapped: GlobalStates.notificationPanelOpen = !GlobalStates.notificationPanelOpen
    }
}
