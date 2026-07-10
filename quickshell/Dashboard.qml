import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

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
    
    transform: Translate {
        id: slideAnim
        x: GlobalStates.dashboardOpen ? 0 : 500
        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
    }

    Rectangle {
        anchors.fill: parent
        radius:       Appearance.size.radius + 8
        color:        Colors.glass
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
            Text {
                text: "Sovereign Hub"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 22
                font.weight: Font.Bold
                color: Colors.text
                Layout.fillWidth: true
            }
            Text {
                text: "󰒲"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 24
                color: Colors.subtext
                
                TapHandler { 
                    onTapped: GlobalStates.dashboardOpen = false 
                }
                
                HoverHandler { id: closeHover }
                color: closeHover.hovered ? Colors.red : Colors.subtext
            }
        }

        // ── 2. MEDYA MERKEZİ ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: Appearance.size.radius + 4
            color: Colors.surface0
            border.color: Colors.surface1
            border.width: 1
            clip: true

            property string title: ""
            property string artist: ""
            property bool playing: false
            
            Process { 
                id: metaProc
                command: ["sh", "-c", "playerctl metadata --format '{{title}}|||{{artist}}' 2>/dev/null"]
                stdout: SplitParser { 
                    onRead: data => { 
                        let t = data.trim(); 
                        if(t && t !== "|||") { 
                            let s = t.indexOf("|||"); 
                            parent.title = s >= 0 ? t.substring(0, s) : t; 
                            parent.artist = s >= 0 ? t.substring(s+3) : ""; 
                        } 
                    } 
                } 
            }
            Process { 
                id: statusProc
                command: ["playerctl", "status"]
                stdout: SplitParser { 
                    onRead: data => parent.playing = (data.trim() === "Playing") 
                } 
            }
            Process { id: playProc; command: ["playerctl", "play-pause"] }
            Process { id: nextProc; command: ["playerctl", "next"] }
            Process { id: prevProc; command: ["playerctl", "previous"] }
            
            Timer { 
                interval: 2000
                running: root.visible
                repeat: true
                onTriggered: { metaProc.running = true; statusProc.running = true; } 
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16
                
                Rectangle {
                    width: 80
                    height: 80
                    radius: 10
                    color: Colors.mantle
                    Text { 
                        anchors.centerIn: parent
                        text: ""
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 32
                        color: Colors.mauve 
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text { 
                        text: parent.parent.title || "Müzik Çalmıyor"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Colors.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true 
                    }
                    Text { 
                        text: parent.parent.artist || "Sovereign Media"
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
                            color: Colors.text
                            TapHandler { onTapped: prevProc.running = true } 
                        }
                        Text { 
                            text: parent.parent.parent.playing ? "󰏦" : "󰐊"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 28
                            color: Colors.mauve
                            TapHandler { 
                                onTapped: {
                                    playProc.running = true; 
                                    parent.parent.parent.playing = !parent.parent.parent.playing 
                                }
                            } 
                        }
                        Text { 
                            text: "󰒭"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 24
                            color: Colors.text
                            TapHandler { onTapped: nextProc.running = true } 
                        }
                    }
                }
            }
        }

        // ── 3. SLIDER ALANI (Ses ve Parlaklık) ──
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16
            
            // Ses Slider
            RowLayout {
                spacing: 16
                Rectangle {
                    width: 40; height: 40; radius: 20; color: Colors.yellow
                    Text { 
                        anchors.centerIn: parent; text: "󰕾"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.base 
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 16; radius: 8; color: Colors.surface0
                    Rectangle { 
                        width: parent.width * (AudioService.volume / 100); height: parent.height; radius: parent.radius; color: Colors.yellow
                        Behavior on width { NumberAnimation { duration: 150 } } 
                    }
                    MouseArea { 
                        anchors.fill: parent
                        onWheel: w => w.angleDelta.y > 0 ? AudioService.raiseVolume() : AudioService.lowerVolume() 
                    }
                }
                Text { 
                    text: AudioService.volume + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.text; Layout.preferredWidth: 40 
                }
            }
            
            // Parlaklık Slider
            RowLayout {
                spacing: 16
                Rectangle {
                    width: 40; height: 40; radius: 20; color: Colors.peach
                    Text { 
                        anchors.centerIn: parent; text: "󰃠"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.base 
                    }
                }
                Rectangle {
                    Layout.fillWidth: true; height: 16; radius: 8; color: Colors.surface0
                    Rectangle { 
                        width: parent.width * (BrightnessService.brightness / 100); height: parent.height; radius: parent.radius; color: Colors.peach
                        Behavior on width { NumberAnimation { duration: 150 } } 
                    }
                    MouseArea { 
                        anchors.fill: parent
                        onWheel: w => w.angleDelta.y > 0 ? BrightnessService.increase() : BrightnessService.decrease() 
                    }
                }
                Text { 
                    text: BrightnessService.brightness + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.text; Layout.preferredWidth: 40 
                }
            }
        }

        // ── 4. HIZLI ŞALTERLER (Toggles) ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 80; radius: 16; color: Colors.blue
                ColumnLayout { 
                    anchors.centerIn: parent; spacing: 6
                    Text { text: ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26; color: Colors.base; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Wi-Fi"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.base; Layout.alignment: Qt.AlignHCenter } 
                }
            }
            
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 80; radius: 16; color: Colors.surface0; border.color: Colors.surface1; border.width: 1
                ColumnLayout { 
                    anchors.centerIn: parent; spacing: 6
                    Text { text: ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26; color: Colors.text; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Bluetooth"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: Colors.text; Layout.alignment: Qt.AlignHCenter } 
                }
            }
            
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 80; radius: 16; color: GlobalStates.zenMode ? Colors.mauve : Colors.surface0; border.color: GlobalStates.zenMode ? "transparent" : Colors.surface1; border.width: 1
                Behavior on color { ColorAnimation { duration: 200 } }
                
                ColumnLayout { 
                    anchors.centerIn: parent; spacing: 6
                    Text { text: "󰘚"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 26; color: GlobalStates.zenMode ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter }
                    Text { text: "Zen Mode"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12; font.weight: Font.Bold; color: GlobalStates.zenMode ? Colors.base : Colors.text; Layout.alignment: Qt.AlignHCenter } 
                }
                
                TapHandler { 
                    onTapped: { 
                        GlobalStates.zenMode = !GlobalStates.zenMode; 
                        Quickshell.execDetached(["notify-send", "Zen Mode", GlobalStates.zenMode ? "Açık" : "Kapalı", "-t", "1500"]); 
                    } 
                }
            }
        }

        // ── 5. SİSTEM MONİTÖRÜ (Kalın Grafikler) ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            radius: Appearance.size.radius + 4
            color: Colors.surface0
            border.color: Colors.surface1
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                RowLayout {
                    spacing: 12
                    Text { text: "󰻠"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20; color: Colors.teal; Layout.preferredWidth: 24; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "CPU"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.subtext; Layout.preferredWidth: 40 }
                    Rectangle { 
                        Layout.fillWidth: true; height: 12; radius: 6; color: Colors.crust
                        Rectangle { 
                            width: parent.width * (SysInfoService.cpuUsage / 100); height: parent.height; radius: parent.radius; color: Colors.teal
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } } 
                        } 
                    }
                    Text { text: SysInfoService.cpuUsage + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.teal; Layout.preferredWidth: 40; horizontalAlignment: Text.AlignRight }
                }
                
                RowLayout {
                    spacing: 12
                    Text { text: "󰾲"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20; color: Colors.green; Layout.preferredWidth: 24; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "GPU"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.subtext; Layout.preferredWidth: 40 }
                    Rectangle { 
                        Layout.fillWidth: true; height: 12; radius: 6; color: Colors.crust
                        Rectangle { 
                            width: parent.width * (SysInfoService.gpuUsage / 100); height: parent.height; radius: parent.radius; color: Colors.green
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } } 
                        } 
                    }
                    Text { text: SysInfoService.gpuUsage + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.green; Layout.preferredWidth: 40; horizontalAlignment: Text.AlignRight }
                }
                
                RowLayout {
                    spacing: 12
                    Text { text: "󰍛"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 20; color: Colors.mauve; Layout.preferredWidth: 24; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "RAM"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.subtext; Layout.preferredWidth: 40 }
                    Rectangle { 
                        Layout.fillWidth: true; height: 12; radius: 6; color: Colors.crust
                        Rectangle { 
                            width: parent.width * (SysInfoService.ramUsage / 100); height: parent.height; radius: parent.radius; color: Colors.mauve
                            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } } 
                        } 
                    }
                    Text { text: SysInfoService.ramUsage + "%"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 14; font.weight: Font.Bold; color: Colors.mauve; Layout.preferredWidth: 40; horizontalAlignment: Text.AlignRight }
                }
            }
        }

        Item { Layout.fillHeight: true }

        // ── 6. GÜÇ KONTROLLERİ ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Rectangle { 
                Layout.fillWidth: true; Layout.preferredHeight: 50; radius: 10; border.width: 1
                color: lockH.hovered ? Colors.surface1 : Colors.surface0
                border.color: Colors.surface1
                
                Text { anchors.centerIn: parent; text: ""; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.text }
                HoverHandler { id: lockH }
                TapHandler { onTapped: Quickshell.execDetached(["hyprlock"]) } 
            }
            
            Rectangle { 
                Layout.fillWidth: true; Layout.preferredHeight: 50; radius: 10; border.width: 1
                color: logH.hovered ? Colors.surface1 : Colors.surface0
                border.color: Colors.surface1
                
                Text { anchors.centerIn: parent; text: "󰍃"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.text }
                HoverHandler { id: logH }
                TapHandler { onTapped: Quickshell.execDetached(["hyprctl", "dispatch", "exit"]) } 
            }
            
            Rectangle { 
                Layout.fillWidth: true; Layout.preferredHeight: 50; radius: 10; border.width: 1
                color: susH.hovered ? Colors.surface1 : Colors.surface0
                border.color: Colors.surface1
                
                Text { anchors.centerIn: parent; text: "󰤄"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.text }
                HoverHandler { id: susH }
                TapHandler { onTapped: Quickshell.execDetached(["systemctl", "suspend"]) } 
            }
            
            Rectangle { 
                Layout.fillWidth: true; Layout.preferredHeight: 50; radius: 10
                color: Colors.red
                scale: powH.hovered ? 1.05 : 1.0
                Behavior on scale { NumberAnimation { duration: 150 } }
                
                Text { anchors.centerIn: parent; text: "󰐥"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18; color: Colors.base }
                HoverHandler { id: powH }
                TapHandler { onTapped: Quickshell.execDetached(["systemctl", "poweroff"]) } 
            }
        }
    }
}
