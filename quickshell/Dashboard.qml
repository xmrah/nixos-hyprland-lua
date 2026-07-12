import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Mpris

PanelWindow {
    id: root
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "sovereign-dashboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { top: true; right: true; bottom: true; left: false }
    margins.top:   Appearance.size.barH + Appearance.size.marginTop + 10
    margins.right: Appearance.size.marginSide
    margins.bottom: Appearance.size.marginSide

    visible: GlobalStates.dashboardOpen
    color:   "transparent"

    implicitWidth:  420

    Rectangle {
        anchors.fill: parent
        radius:       Appearance.size.radius + 8
        color:        Qt.rgba(0.118, 0.118, 0.180, 0.85)
        border.color: Colors.glassBorder
        border.width: 1
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        // ── 1. HEADER ──
        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "Sovereign Hub"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    font.weight: Font.Bold
                    color: Colors.text
                }
                Text {
                    text: "Sisteme Hoş Geldiniz"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    color: Colors.subtext
                }
            }
            
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: closeHover.hovered ? Colors.surface1 : "transparent"
                Text {
                    anchors.centerIn: parent
                    text: "" // Çarpı ikonu (Zzz yerine)
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    color: closeHover.hovered ? Colors.red : Colors.subtext
                }
                TapHandler { 
                    onTapped: GlobalStates.dashboardOpen = false 
                }
                HoverHandler { id: closeHover; cursorShape: Qt.PointingHandCursor }
            }
        }

        // ── 2. MEDYA MERKEZİ (MPRIS) ──
        Rectangle {
            id: mediaBox
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: Appearance.size.radius + 4
            color: Colors.surface0
            border.color: Colors.surface1
            border.width: 1
            clip: true

            // Oynatılan bir medya var mı
            property var player: Mpris.players.length > 0 ? Mpris.players[0] : null
            property bool hasArt: player && player.trackArtUrl && player.trackArtUrl !== ""
            property bool isPlaying: player && player.playbackState === Mpris.Playing

            // Kapak fotoğrafı arka plan bluru
            Image {
                anchors.fill: parent
                source: mediaBox.hasArt ? mediaBox.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                opacity: 0.15
                visible: mediaBox.hasArt
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                Rectangle {
                    width: 80
                    height: 80
                    radius: 12
                    color: mediaBox.hasArt ? "transparent" : Colors.mantle
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: mediaBox.hasArt ? mediaBox.player.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: mediaBox.hasArt
                    }

                    Text { 
                        id: fallbackMusicIcon
                        anchors.centerIn: parent
                        text: ""
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 32
                        color: mediaBox.isPlaying ? Colors.peach : Colors.mauve 
                        visible: !mediaBox.hasArt
                        
                        // Ruhsuzluğu Gidermek İçin Nabız Animasyonu (Müzik çalarken)
                        SequentialAnimation on scale {
                            running: mediaBox.isPlaying && !mediaBox.hasArt
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.15; duration: 600; easing.type: Easing.InOutQuad }
                            NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
                        }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { 
                        text: mediaBox.player ? (mediaBox.player.trackTitle || (mediaBox.isPlaying ? "Oynatılıyor (Meta Veri Yok)" : "Bilinmeyen Parça")) : "Müzik Çalmıyor"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Colors.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true 
                    }
                    Text { 
                        text: mediaBox.player ? (mediaBox.player.trackArtist || (mediaBox.isPlaying ? "YouTube / Tarayıcı" : "Sovereign Media")) : "Şu an oynatılan bir medya yok"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        color: Colors.subtext
                        elide: Text.ElideRight
                        Layout.fillWidth: true 
                    }
                    Item { Layout.fillHeight: true }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        Layout.alignment: Qt.AlignHCenter
                        
                        Text { 
                            text: "󰒮"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 24
                            color: mediaBox.player && mediaBox.player.canGoPrevious ? Colors.text : Colors.surface1
                            TapHandler { onTapped: { if(mediaBox.player) mediaBox.player.previous() } } 
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                        }
                        Text { 
                            text: mediaBox.isPlaying ? "󰏦" : "󰐊"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 28
                            color: mediaBox.player ? Colors.mauve : Colors.surface1
                            TapHandler { 
                                onTapped: { if(mediaBox.player) mediaBox.player.togglePlaying() }
                            }
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                        }
                        Text { 
                            text: "󰒭"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 24
                            color: mediaBox.player && mediaBox.player.canGoNext ? Colors.text : Colors.surface1
                            TapHandler { onTapped: { if(mediaBox.player) mediaBox.player.next() } } 
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                        }
                    }
                }
            }
            
            // Progress Bar
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 3
                color: Colors.surface1
                Rectangle {
                    height: parent.height
                    color: Colors.mauve
                    width: mediaBox.player && mediaBox.player.trackLength > 0 ? parent.width * (mediaBox.player.position / mediaBox.player.trackLength) : 0
                    Behavior on width { NumberAnimation { duration: 500 } }
                }
            }
        }

        // ── 3. SLIDER ALANI (Ses ve Parlaklık) ──
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            
            RowLayout {
                spacing: 16
                Rectangle {
                    width: 40; height: 40; radius: 20; color: Colors.yellow
                    Text { anchors.centerIn: parent; text: "󰕾"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.base }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 16; radius: 8; color: Colors.surface0
                    border.color: Colors.surface1; border.width: 1
                    Rectangle { 
                        width: Math.max(parent.width * (AudioService.volume / 100), parent.height); height: parent.height; radius: parent.radius; color: Colors.yellow
                        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } } 
                    }
                    MouseArea { 
                        anchors.fill: parent
                        onWheel: w => w.angleDelta.y > 0 ? AudioService.raiseVolume() : AudioService.lowerVolume() 
                    }
                }
                Text { text: AudioService.volume + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.text; Layout.preferredWidth: 40; horizontalAlignment: Text.AlignRight }
            }
            
            RowLayout {
                spacing: 16
                Rectangle {
                    width: 40; height: 40; radius: 20; color: Colors.peach
                    Text { anchors.centerIn: parent; text: "󰃠"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.base }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 16; radius: 8; color: Colors.surface0
                    border.color: Colors.surface1; border.width: 1
                    Rectangle { 
                        width: Math.max(parent.width * (BrightnessService.brightness / 100), parent.height); height: parent.height; radius: parent.radius; color: Colors.peach
                        Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } } 
                    }
                    MouseArea { 
                        anchors.fill: parent
                        onWheel: w => w.angleDelta.y > 0 ? BrightnessService.increase() : BrightnessService.decrease() 
                    }
                }
                Text { text: BrightnessService.brightness + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.text; Layout.preferredWidth: 40; horizontalAlignment: Text.AlignRight }
            }
        }

        // ── 4. HIZLI ŞALTERLER (Toggles) ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            // Wi-Fi
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 14; color: Colors.blue
                ColumnLayout { 
                    anchors.centerIn: parent; spacing: 4
                    Text { text: ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 22; color: Colors.base; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Wi-Fi"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.weight: Font.Bold; color: Colors.base; Layout.alignment: Qt.AlignHCenter } 
                }
            }
            
            // Night Light
            Rectangle {
                property bool isActive: false
                Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 14; 
                color: isActive ? Colors.peach : Colors.surface0; border.color: isActive ? "transparent" : Colors.surface1; border.width: 1
                Behavior on color { ColorAnimation { duration: 200 } }
                ColumnLayout { 
                    anchors.centerIn: parent; spacing: 4
                    Text { text: "󰖔"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 22; color: parent.parent.isActive ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Gece Işığı"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.weight: Font.Bold; color: parent.parent.isActive ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter } 
                }
                TapHandler { 
                    onTapped: { 
                        parent.isActive = !parent.isActive; 
                        if (parent.isActive) {
                            Quickshell.execDetached(["wlsunset", "-T", "4500"]);
                        } else {
                            Quickshell.execDetached(["killall", "wlsunset"]);
                        }
                    } 
                }
                HoverHandler { cursorShape: Qt.PointingHandCursor }
            }
            
            // Mic Mute
            Rectangle {
                property bool isMuted: false
                Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 14; 
                color: isMuted ? Colors.red : Colors.surface0; border.color: isMuted ? "transparent" : Colors.surface1; border.width: 1
                Behavior on color { ColorAnimation { duration: 200 } }
                ColumnLayout { 
                    anchors.centerIn: parent; spacing: 4
                    Text { text: parent.parent.isMuted ? "󰍭" : "󰍬"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 22; color: parent.parent.isMuted ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Mikrofon"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.weight: Font.Bold; color: parent.parent.isMuted ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter } 
                }
                TapHandler { 
                    onTapped: { 
                        parent.isMuted = !parent.isMuted; 
                        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]); 
                    } 
                }
                HoverHandler { cursorShape: Qt.PointingHandCursor }
            }

            // DND
            Rectangle {
                property bool dnd: false
                Layout.fillWidth: true; Layout.preferredHeight: 70; radius: 14; 
                color: dnd ? Colors.mauve : Colors.surface0; border.color: dnd ? "transparent" : Colors.surface1; border.width: 1
                Behavior on color { ColorAnimation { duration: 200 } }
                ColumnLayout { 
                    anchors.centerIn: parent; spacing: 4
                    Text { text: parent.parent.dnd ? "󰂛" : "󰂚"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 22; color: parent.parent.dnd ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "DND Mode"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.weight: Font.Bold; color: parent.parent.dnd ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter } 
                }
                TapHandler { 
                    onTapped: { 
                        parent.dnd = !parent.dnd; 
                        Quickshell.execDetached(["makoctl", "mode", "-s", parent.dnd ? "dnd" : "default"]); 
                    } 
                }
                HoverHandler { cursorShape: Qt.PointingHandCursor }
            }
        }

        // ── 5. SİSTEM MONİTÖRÜ (GB ve Process Listesi) ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true  // Layout.preferredHeight kaldırıldı ki dinamik büyüsün
            radius: Appearance.size.radius + 4
            color: Colors.surface0
            border.color: Colors.surface1
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                // CPU (% - CPU'nun GB'ı olmadığı için % kalır)
                RowLayout {
                    spacing: 12
                    Text { text: "󰻠"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20; color: Colors.teal; Layout.preferredWidth: 24; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "CPU"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.subtext; Layout.preferredWidth: 40 }
                    Rectangle { 
                        Layout.fillWidth: true; height: 14; radius: 7; color: Colors.crust
                        Rectangle { 
                            width: Math.max(parent.width * (SysInfoService.cpuUsage / 100), parent.height); height: parent.height; radius: parent.radius; color: Colors.teal
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } } 
                        } 
                    }
                    Text { text: SysInfoService.cpuUsage + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.teal; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                }
                
                // VRAM (GB)
                RowLayout {
                    spacing: 12
                    Text { text: "󰾲"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20; color: Colors.green; Layout.preferredWidth: 24; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "VRAM"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.subtext; Layout.preferredWidth: 40 }
                    Rectangle { 
                        Layout.fillWidth: true; height: 14; radius: 7; color: Colors.crust
                        Rectangle { 
                            width: Math.max(parent.width * (SysInfoService.vramUsage / 100), parent.height); height: parent.height; radius: parent.radius; color: Colors.green
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } } 
                        } 
                    }
                    Text { text: SysInfoService.vramText; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.green; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                }
                
                // RAM (GB)
                RowLayout {
                    spacing: 12
                    Text { text: "󰍛"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20; color: Colors.mauve; Layout.preferredWidth: 24; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "RAM"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.subtext; Layout.preferredWidth: 40 }
                    Rectangle { 
                        Layout.fillWidth: true; height: 14; radius: 7; color: Colors.crust
                        Rectangle { 
                            width: Math.max(parent.width * (SysInfoService.ramUsage / 100), parent.height); height: parent.height; radius: parent.radius; color: Colors.mauve
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } } 
                        } 
                    }
                    Text { text: SysInfoService.ramText; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.mauve; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                }

                // Ayıraç
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.surface1
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                }

                // Process Listesi (Top 5)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    
                    Text {
                        text: "En Çok Bellek Tüketenler"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        color: Colors.subtext
                        font.weight: Font.Bold
                        Layout.bottomMargin: 4
                    }

                    Repeater {
                        model: SysInfoService.topProcesses
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            Text { text: "󰘚"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; color: Colors.overlay0 }
                            Text { 
                                text: modelData.name 
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                color: Colors.text
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            Text {
                                text: modelData.mem
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                color: Colors.mauve
                                font.weight: Font.Bold
                            }
                        }
                    }
                    
                    // Veri henüz gelmediyse veya boşsa yedek yazı
                    Text {
                        text: "İşlemler yükleniyor..."
                        visible: SysInfoService.topProcesses.length === 0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        color: Colors.overlay0
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // ── 6. GÜÇ KONTROLLERİ ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Rectangle { 
                Layout.fillWidth: true; Layout.preferredHeight: 50; radius: 12; border.width: 1
                color: lockH.hovered ? Colors.surface1 : Colors.surface0
                border.color: Colors.surface1
                Text { anchors.centerIn: parent; text: ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.text }
                HoverHandler { id: lockH; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: Quickshell.execDetached(["hyprlock"]) } 
            }
            
            Rectangle { 
                Layout.fillWidth: true; Layout.preferredHeight: 50; radius: 12; border.width: 1
                color: logH.hovered ? Colors.surface1 : Colors.surface0
                border.color: Colors.surface1
                Text { anchors.centerIn: parent; text: "󰍃"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.text }
                HoverHandler { id: logH; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: Quickshell.execDetached(["hyprctl", "dispatch", "exit"]) } 
            }
            
            Rectangle { 
                Layout.fillWidth: true; Layout.preferredHeight: 50; radius: 12; border.width: 1
                color: susH.hovered ? Colors.surface1 : Colors.surface0
                border.color: Colors.surface1
                Text { anchors.centerIn: parent; text: "󰤄"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.text }
                HoverHandler { id: susH; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: Quickshell.execDetached(["systemctl", "suspend"]) } 
            }

            Rectangle { 
                Layout.fillWidth: true; Layout.preferredHeight: 50; radius: 12; border.width: 1
                color: rebH.hovered ? Colors.yellow : Colors.surface0
                border.color: rebH.hovered ? "transparent" : Colors.surface1
                Behavior on color { ColorAnimation { duration: 150 } }
                Text { anchors.centerIn: parent; text: "󰑓"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: rebH.hovered ? Colors.crust : Colors.text }
                HoverHandler { id: rebH; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: Quickshell.execDetached(["systemctl", "reboot"]) } 
            }
            
            Rectangle { 
                Layout.fillWidth: true; Layout.preferredHeight: 50; radius: 12
                color: Colors.red
                scale: powH.hovered ? 1.05 : 1.0
                Behavior on scale { NumberAnimation { duration: 150 } }
                Text { anchors.centerIn: parent; text: "󰐥"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.base }
                HoverHandler { id: powH; cursorShape: Qt.PointingHandCursor }
                TapHandler { onTapped: Quickshell.execDetached(["systemctl", "poweroff"]) } 
            }
        }
    }
}
