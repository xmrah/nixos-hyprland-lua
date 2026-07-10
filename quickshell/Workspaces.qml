import QtQuick
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root
    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 14
    radius:         Appearance.size.radiusSm
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(1, 1, 1, 0.07)
    border.width:   1

    readonly property int activeId: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1

    function isOccupied(id) {
        for (let i = 0; i < Hyprland.workspaces.length; i++) {
            if (Hyprland.workspaces[i].id === id && Hyprland.workspaces[i].windows > 0)
                return true
        }
        return false
    }

    function windowCount(id) {
        for (let i = 0; i < Hyprland.workspaces.length; i++) {
            if (Hyprland.workspaces[i].id === id)
                return Hyprland.workspaces[i].windows
        }
        return 0
    }

    // Scratchpad (özel workspace: id < 0) pencere var mı?
    readonly property bool scratchpadOccupied: {
        for (let i = 0; i < Hyprland.workspaces.length; i++) {
            if (Hyprland.workspaces[i].id < 0 && Hyprland.workspaces[i].windows > 0)
                return true
        }
        return false
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: 9

            delegate: Item {
                id: btn
                readonly property int  wsId:     modelData + 1
                readonly property bool isActive: wsId === root.activeId
                readonly property bool occupied: root.isOccupied(wsId)
                // Aktif workspace: focusedMonitor.activeWorkspace.windows (reaktif, doğrudan IPC)
                // Non-aktif: workspaces listesindeki nesneye direkt binding
                readonly property int winCount: {
                    if (wsId === root.activeId)
                        return Hyprland.focusedMonitor?.activeWorkspace?.windows ?? 0
                    return root.windowCount(wsId)
                }

                implicitWidth:  isActive ? 28 : 8
                implicitHeight: 30

                Behavior on implicitWidth { NumberAnimation { duration: Appearance.anim.ws.dur; easing.type: Easing.OutCubic } }

                // Pencere sayısı rozeti (aktif olmayan dolular için)
                Text {
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 1 }
                    visible:        btn.occupied && !btn.isActive && btn.winCount > 1
                    text:           btn.winCount
                    font.family:    "JetBrainsMono Nerd Font"
                    font.pixelSize: 7
                    font.weight:    Font.Bold
                    color:          Qt.rgba(0.490, 0.812, 1.0, 0.75)
                }

                Rectangle {
                    anchors.centerIn: parent
                    width:  btn.isActive ? 28 : (btn.occupied ? 7 : 5)
                    height: btn.isActive ? 20 : (btn.occupied ? 7 : 5)
                    radius: btn.isActive ? 6 : 10

                    color: btn.isActive  ? Qt.rgba(0.490, 0.812, 1.0, 0.22)
                         : btn.occupied  ? Qt.rgba(0.490, 0.812, 1.0, 0.50)
                         :                 Qt.rgba(1, 1, 1, 0.15)

                    border.color: btn.isActive ? Qt.rgba(0.490, 0.812, 1.0, 0.65) : "transparent"
                    border.width: btn.isActive ? 1 : 0

                    Behavior on width        { NumberAnimation { duration: Appearance.anim.ws.dur; easing.type: Easing.OutCubic } }
                    Behavior on height       { NumberAnimation { duration: Appearance.anim.ws.dur; easing.type: Easing.OutCubic } }
                    Behavior on color        { ColorAnimation  { duration: Appearance.anim.fast.dur } }
                    Behavior on border.color { ColorAnimation  { duration: Appearance.anim.fast.dur } }

                    // Aktif workspace: numara + pencere sayısı
                    Row {
                        anchors.centerIn: parent
                        visible:  btn.isActive
                        spacing:  2

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text:           btn.wsId
                            font.family:    "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            font.weight:    Font.Bold
                            color:          "#7dcfff"
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible:        btn.winCount > 0
                            text:           "·" + btn.winCount
                            font.family:    "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            font.weight:    Font.Bold
                            color:          Qt.rgba(0.490, 0.812, 1.0, 0.60)
                        }
                    }
                }

                TapHandler { onTapped: Hyprland.dispatch("workspace " + btn.wsId) }
            }
        }

        // Scratchpad indikatörü — magic workspace'te pencere varsa görünür
        Item {
            implicitWidth:  root.scratchpadOccupied ? 14 : 0
            implicitHeight: 30
            clip: true
            Behavior on implicitWidth { NumberAnimation { duration: Appearance.anim.ws.dur; easing.type: Easing.OutCubic } }

            Rectangle {
                anchors.centerIn: parent
                width:  10
                height: 10
                radius: 5
                color:  Qt.rgba(0.784, 0.404, 0.980, 0.50)
                border.color: Qt.rgba(0.784, 0.404, 0.980, 0.80)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text:           "S"
                    font.family:    "JetBrainsMono Nerd Font"
                    font.pixelSize: 7
                    font.weight:    Font.Bold
                    color:          "#cba6f7"
                }
            }

            TapHandler { onTapped: Hyprland.dispatch("togglespecialworkspace magic") }
        }
    }
}
