import QtQuick
import Quickshell
import Quickshell.Io

// ═══════════════════════════════════════════════════════════════════
// Sovereign Quick Settings & Dashboard Capsule
// Kompakt durum (Ağ, Ses) + mouse wheel ile ses kontrolü + Hub trigger
// ═══════════════════════════════════════════════════════════════════
Rectangle {
    id: root

    property bool   netConnected: true
    property bool   isEthernet:   false
    property string netSsid:      ""

    implicitHeight: Appearance.size.widgetH
    implicitWidth:  contentRow.implicitWidth + 20
    radius:         Appearance.size.radiusSm
    color:          GlobalStates.dashboardOpen
                        ? Colors.surface1
                        : (hov.hovered ? Qt.rgba(0.25, 0.25, 0.35, 0.65) : Qt.rgba(0.118, 0.118, 0.180, 0.65))
    border.color:   GlobalStates.dashboardOpen
                        ? Colors.blue
                        : (hov.hovered ? Qt.rgba(0.537, 0.706, 0.980, 0.40) : Qt.rgba(1, 1, 1, 0.08))
    border.width:   1

    Behavior on color        { ColorAnimation { duration: Appearance.anim.fast.dur } }
    Behavior on border.color { ColorAnimation { duration: Appearance.anim.fast.dur } }

    // Ağ durumu kontrolü (Locale-Agnostic WiFi + Ethernet Fallback)
    Process {
        id: netProc
        command: ["sh", "-c", "wifi=$(LC_ALL=C nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 | head -1); if [ -n \"$wifi\" ]; then echo \"WIFI:$wifi\"; elif ip route show default 2>/dev/null | grep -q 'proto'; then echo \"ETH:Kablolu\"; else echo \"NONE\"; fi"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const s = data.trim()
                if (s.startsWith("WIFI:")) {
                    root.netConnected = true
                    root.isEthernet   = false
                    root.netSsid      = s.substring(5)
                } else if (s.startsWith("ETH:")) {
                    root.netConnected = true
                    root.isEthernet   = true
                    root.netSsid      = "Kablolu Ağ"
                } else {
                    root.netConnected = false
                    root.isEthernet   = false
                    root.netSsid      = "Bağlantı Yok"
                }
            }
        }
    }
    Timer {
        interval: 10000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: if (!netProc.running) netProc.running = true
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 8

        // Ağ İkonu (WiFi vs Ethernet)
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.netConnected ? (root.isEthernet ? "󰈀" : "󰤨") : "󰤮"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            color: root.netConnected ? "#a6e3a1" : "#f38ba8"
        }

        // Ses İkonu + Seviye
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: (AudioService.muted ? "󰝟" : (AudioService.volume < 40 ? "󰕿" : "󰕾"))
                  + " " + (AudioService.muted ? "0%" : AudioService.volume + "%")
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.weight:    Font.Medium
            color: AudioService.muted ? Colors.subtext : "#f9e2af"
        }

        // İnce Ayırıcı Çizgi
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width:  1
            height: 12
            color:  Qt.rgba(1, 1, 1, 0.15)
        }

        // Sovereign Hub İkonu
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰍜"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: 15
            color: GlobalStates.dashboardOpen ? Colors.blue : Colors.text
        }
    }

    HoverHandler { id: hov }

    TapHandler {
        onTapped: GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen
    }

    // Doğrudan bar üzerinden ses açma / kısma (Mouse Wheel)
    MouseArea {
        anchors.fill:    parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) AudioService.raiseVolume()
            else                        AudioService.lowerVolume()
        }
    }
}
