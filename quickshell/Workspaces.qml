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

    // ── AKILLI İKON HARİTALAMASI (Smart Icon Mapping) ──
    function getIconForClass(cls) {
        if (!cls) return ""
        let c = cls.toLowerCase()
        if (c.indexOf("kitty") !== -1 || c.indexOf("alacritty") !== -1 || c.indexOf("wezterm") !== -1) return ""
        if (c.indexOf("firefox") !== -1 || c.indexOf("chromium") !== -1 || c.indexOf("brave") !== -1) return ""
        if (c.indexOf("code") !== -1 || c.indexOf("vscodium") !== -1 || c.indexOf("neovim") !== -1) return ""
        if (c.indexOf("discord") !== -1 || c.indexOf("telegram") !== -1 || c.indexOf("slack") !== -1) return ""
        if (c.indexOf("spotify") !== -1 || c.indexOf("mpv") !== -1 || c.indexOf("vlc") !== -1) return ""
        if (c.indexOf("thunar") !== -1 || c.indexOf("dolphin") !== -1 || c.indexOf("nemo") !== -1) return ""
        if (c.indexOf("obsidian") !== -1) return ""
        return "" // Tanınmayan uygulamalar için standart daire
    }

    // Çalışma alanındaki uygulamaları tarar ve ikonlarını (tekrar etmeden) birleştirir
    function getWorkspaceIcons(wsId) {
        let icons = []
        for (let i = 0; i < Hyprland.clients.length; i++) {
            let client = Hyprland.clients[i]
            if (client.workspace && client.workspace.id === wsId) {
                let icon = getIconForClass(client.class)
                if (icons.indexOf(icon) === -1) {
                    icons.push(icon)
                }
            }
        }
        return icons.join(" ")
    }

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
                readonly property string wsIcons: root.getWorkspaceIcons(wsId)

                // Aktifse daha geniş (ikonlara yer açmak için)
                implicitWidth:  isActive ? Math.max(28, metrics.width + 16) : 8
                implicitHeight: 30

                TextMetrics {
                    id: metrics
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    text: btn.wsIcons !== "" ? btn.wsIcons : btn.wsId.toString()
                }

                Behavior on implicitWidth { NumberAnimation { duration: Appearance.anim.ws.dur; easing.type: Easing.OutCubic } }

                // İnaktif ama dolu alanlar için dışarda duran küçük uygulama ikonları (Eski winCount yerine)
                Text {
                    anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 1 }
                    visible:        btn.occupied && !btn.isActive && btn.wsIcons !== ""
                    text:           btn.wsIcons
                    font.family:    "JetBrainsMono Nerd Font"
                    font.pixelSize: 8
                    font.weight:    Font.Bold
                    color:          Qt.rgba(0.490, 0.812, 1.0, 0.75)
                }

                Rectangle {
                    anchors.centerIn: parent
                    width:  btn.isActive ? parent.implicitWidth : (btn.occupied ? 7 : 5)
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

                    // Aktif Workspace İçeriği
                    Row {
                        anchors.centerIn: parent
                        visible:  btn.isActive
                        spacing:  4

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            // Uygulama yoksa numara göster, varsa ikonları göster
                            text:           btn.wsIcons !== "" ? btn.wsIcons : btn.wsId
                            font.family:    "JetBrainsMono Nerd Font"
                            font.pixelSize: 13
                            font.weight:    Font.Bold
                            color:          "#7dcfff"
                        }
                    }
                }

                TapHandler { onTapped: Hyprland.dispatch("workspace " + btn.wsId) }
            }
        }

        // Scratchpad indikatörü
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
