import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    property int count: 0
    readonly property bool hasNotifications: count > 0

    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 16
    radius:         Appearance.size.radius
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   hasNotifications
                        ? Qt.rgba(0.651, 0.890, 0.631, 0.35)
                        : Qt.rgba(1, 1, 1, 0.07)
    border.width:   1

    Behavior on border.color { ColorAnimation { duration: Appearance.anim.fast.dur } }

    // IPC Handler — bildirim sayısını dışarıdan güncellemek için
    IpcHandler {
        target: "notifications"
        function toggle() {
            // TODO: Quickshell native bildirim paneli implemente edilecek
            // Şimdilik bildirim sayacını sıfırla
            root.count = 0
        }
        function updateCount(n) {
            root.count = n
        }
    }

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

    TapHandler {
        // TODO: Native bildirim paneli açılacak
        onTapped: root.count = 0
    }
}
