import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Mpris

PanelWindow {
    id: root
    exclusionMode:               ExclusionMode.Ignore
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "sovereign-dashboard"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors { top: true; right: true; bottom: true; left: false }
    margins.top:   Appearance.size.barH + Appearance.size.marginTop + 10
    margins.right: Appearance.size.marginSide
    margins.bottom: Appearance.size.marginSide

    visible: GlobalStates.dashboardOpen
    color:   "transparent"

    implicitWidth:  440

    // ── Wi-Fi ve Bluetooth Durum Yönetimi ──
    property bool wifiDrawerOpen: false
    property bool btDrawerOpen: false
    property var wifiNetworks: []
    property var btDevices: []
    property bool wifiScanning: false
    property bool btScanning: false
    property string activeSsid: ""
    property bool wifiEnabled: true
    property bool btEnabled: false
    property string selectedSsid: ""

    // Wi-Fi Durumu & Tarama
    Process {
        id: wifiScanProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "dev", "wifi", "list"]
        running: false
        stdout: StdioCollector {
            id: wifiCollector
            onStreamFinished: {
                root.wifiScanning = false;
                let text = wifiCollector.text || "";
                let lines = text.split("\n");
                let map = {};
                let list = [];
                let currentActive = "";
                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (!line) continue;
                    let san = line.replace(/\\:/g, "__COLON__");
                    let parts = san.split(":");
                    if (parts.length >= 4) {
                        let ssid = parts[0].replace(/__COLON__/g, ":").trim();
                        if (!ssid) continue;
                        let signal = parseInt(parts[1]) || 0;
                        let sec = parts[2].replace(/__COLON__/g, ":").trim();
                        let inUse = parts[3].trim() === "*";
                        if (inUse) currentActive = ssid;
                        if (!map[ssid] || inUse || signal > map[ssid].signal) {
                            map[ssid] = { ssid: ssid, signal: signal, isSecure: sec.length > 0, security: sec, inUse: inUse };
                        }
                    }
                }
                for (let k in map) list.push(map[k]);
                list.sort((a, b) => (b.inUse ? 1 : 0) - (a.inUse ? 1 : 0) || b.signal - a.signal);
                root.wifiNetworks = list;
                root.activeSsid = currentActive;
            }
        }
    }

    // Wi-Fi Radio Durumu Kontrolü
    Process {
        id: wifiRadioCheckProc
        command: ["nmcli", "radio", "wifi"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                root.wifiEnabled = (data.trim() === "enabled");
            }
        }
    }

    // Bluetooth Durumu & Cihaz Tarama
    Process {
        id: btScanProc
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | grep 'Powered:'; echo '---CONN---'; bluetoothctl devices 2>/dev/null; echo '---ACTV---'; bluetoothctl devices Connected 2>/dev/null"]
        running: false
        stdout: StdioCollector {
            id: btCollector
            onStreamFinished: {
                root.btScanning = false;
                let text = btCollector.text || "";
                let sections = text.split("---CONN---");
                let showRaw = sections[0] || "";
                root.btEnabled = showRaw.indexOf("Powered: yes") !== -1;

                let rest = sections[1] || "";
                let devSections = rest.split("---ACTV---");
                let pairedRaw = devSections[0] || "";
                let connRaw = devSections[1] || "";

                let connMacs = {};
                let connLines = connRaw.split("\n");
                for (let c of connLines) {
                    c = c.trim();
                    if (c.startsWith("Device ")) {
                        let p = c.split(" ");
                        if (p.length > 1) connMacs[p[1]] = true;
                    }
                }

                let list = [];
                let pairedLines = pairedRaw.split("\n");
                for (let p of pairedLines) {
                    p = p.trim();
                    if (p.startsWith("Device ")) {
                        let parts = p.split(" ");
                        let mac = parts[1];
                        let name = parts.slice(2).join(" ") || mac;
                        list.push({ mac: mac, name: name, connected: !!connMacs[mac] });
                    }
                }
                list.sort((a, b) => (b.connected ? 1 : 0) - (a.connected ? 1 : 0));
                root.btDevices = list;
            }
        }
    }

    Timer {
        id: wifiScanTimer
        interval: 1500
        running: false
        onTriggered: {
            root.wifiScanning = true;
            wifiScanProc.running = true;
            wifiRadioCheckProc.running = true;
        }
    }

    Timer {
        id: btScanTimer
        interval: 1500
        running: false
        onTriggered: {
            root.btScanning = true;
            btScanProc.running = true;
        }
    }

    Connections {
        target: GlobalStates
        function onDashboardOpenChanged() {
            if (GlobalStates.dashboardOpen) {
                wifiRadioCheckProc.running = true;
                if (!wifiScanProc.running) {
                    root.wifiScanning = true;
                    wifiScanProc.running = true;
                }
                if (!btScanProc.running) {
                    root.btScanning = true;
                    btScanProc.running = true;
                }
            } else {
                root.wifiDrawerOpen = false;
                root.btDrawerOpen = false;
                root.selectedSsid = "";
            }
        }
    }

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

        // ── 2. MEDYA MERKEZİ (PLAYERCTL) ──
        Rectangle {
            id: mediaBox
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: Appearance.size.radius + 4
            color: Colors.surface0
            border.color: Colors.surface1
            border.width: 1
            clip: true

            property string trackTitle: ""
            property string trackArtist: ""
            property string trackArtUrl: ""
            property bool isPlaying: false
            property bool hasArt: trackArtUrl !== ""
            
            // Metadata okuma (title|||artist|||artUrl)
            Process {
                id: metaProc
                command: ["sh", "-c", "playerctl metadata --format '{{title}}|||{{artist}}|||{{mpris:artUrl}}' 2>/dev/null || echo '||||||'"]
                running: false
                stdout: SplitParser {
                    onRead: data => {
                        let t = data.trim()
                        if (t && t !== "||||||") {
                            let parts = t.split("|||")
                            mediaBox.trackTitle = parts[0] || ""
                            mediaBox.trackArtist = parts[1] || ""
                            let art = parts[2] || ""
                            if (art.startsWith("file://") || art.startsWith("http")) {
                                mediaBox.trackArtUrl = art
                            } else {
                                mediaBox.trackArtUrl = ""
                            }
                        } else {
                            mediaBox.trackTitle = ""
                            mediaBox.trackArtist = ""
                            mediaBox.trackArtUrl = ""
                        }
                    }
                }
            }

            // Durum okuma (Playing / Paused)
            Process {
                id: statusProc
                command: ["sh", "-c", "playerctl status 2>/dev/null || echo 'Stopped'"]
                running: false
                stdout: SplitParser {
                    onRead: data => { mediaBox.isPlaying = (data.trim() === "Playing") }
                }
            }

            Timer {
                interval: 2000; running: GlobalStates.dashboardOpen; repeat: true; triggeredOnStart: true
                onTriggered: { metaProc.running = true; statusProc.running = true; }
            }

            // Kapak fotoğrafı arka plan bluru
            Image {
                anchors.fill: parent
                source: mediaBox.hasArt ? mediaBox.trackArtUrl : ""
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
                        source: mediaBox.hasArt ? mediaBox.trackArtUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: mediaBox.hasArt
                    }

                    Text { 
                        anchors.centerIn: parent
                        text: ""
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 32
                        color: mediaBox.isPlaying ? Colors.peach : Colors.mauve 
                        visible: !mediaBox.hasArt
                        
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
                        text: mediaBox.trackTitle !== "" ? mediaBox.trackTitle : (mediaBox.isPlaying ? "Oynatılıyor (İsimsiz)" : "Müzik Çalmıyor")
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        color: Colors.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true 
                    }
                    Text { 
                        text: mediaBox.trackArtist !== "" ? mediaBox.trackArtist : (mediaBox.isPlaying ? "Bilinmeyen Sanatçı" : "Şu an oynatılan bir medya yok")
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
                            TapHandler { onTapped: Quickshell.execDetached(["playerctl", "previous"]) } 
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                        }
                        Text { 
                            text: mediaBox.isPlaying ? "󰏦" : "󰐊"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 28
                            color: Colors.mauve
                            TapHandler { onTapped: Quickshell.execDetached(["playerctl", "play-pause"]) }
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                        }
                        Text { 
                            text: "󰒭"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 24
                            color: Colors.text
                            TapHandler { onTapped: Quickshell.execDetached(["playerctl", "next"]) } 
                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                        }
                    }
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
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            // Üst Satır: Wi-Fi, Bluetooth, Kasa
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // 1. Wi-Fi Butonu & Çekmece Tetikleyici
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 14
                    color: root.wifiDrawerOpen ? Qt.rgba(0.537, 0.706, 0.980, 0.25)
                         : (root.activeSsid !== "" ? Qt.rgba(0.537, 0.706, 0.980, 0.18) : Colors.surface0)
                    border.color: root.wifiDrawerOpen || root.activeSsid !== "" ? Colors.blue : Colors.surface1
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: root.activeSsid !== "" ? "󰤨" : (root.wifiEnabled ? "󰤥" : "󰤮")
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 20
                            color: root.activeSsid !== "" ? Colors.blue : Colors.subtext
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Wi-Fi"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: Colors.text
                            }
                            Text {
                                text: root.activeSsid !== "" ? root.activeSsid : (root.wifiEnabled ? "Açık" : "Kapalı")
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                color: root.activeSsid !== "" ? Colors.blue : Colors.subtext
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        Text {
                            text: root.wifiDrawerOpen ? "󰅃" : "󰅀"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            color: Colors.subtext
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    HoverHandler { id: wifiHov; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            root.wifiDrawerOpen = !root.wifiDrawerOpen;
                            if (root.wifiDrawerOpen) {
                                root.btDrawerOpen = false;
                                root.wifiScanning = true;
                                wifiScanProc.running = true;
                            }
                        }
                    }
                }

                // 2. Bluetooth Butonu & Çekmece Tetikleyici
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 14
                    color: root.btDrawerOpen ? Qt.rgba(0.796, 0.651, 0.969, 0.25)
                         : (root.btDevices.some(d => d.connected) ? Qt.rgba(0.796, 0.651, 0.969, 0.18) : Colors.surface0)
                    border.color: root.btDrawerOpen || root.btDevices.some(d => d.connected) ? Colors.mauve : Colors.surface1
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: root.btDevices.some(d => d.connected) ? "󰂱" : (root.btEnabled ? "󰂯" : "󰂲")
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 20
                            color: root.btDevices.some(d => d.connected) ? Colors.mauve : Colors.subtext
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Bluetooth"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: Colors.text
                            }
                            Text {
                                text: root.btEnabled ? (root.btDevices.find(d => d.connected)?.name || "Açık") : "Kapalı"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                color: root.btDevices.some(d => d.connected) ? Colors.mauve : Colors.subtext
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        Text {
                            text: root.btDrawerOpen ? "󰅃" : "󰅀"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            color: Colors.subtext
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    HoverHandler { id: btHov; cursorShape: Qt.PointingHandCursor }
                    TapHandler {
                        onTapped: {
                            root.btDrawerOpen = !root.btDrawerOpen;
                            if (root.btDrawerOpen) {
                                root.wifiDrawerOpen = false;
                                root.btScanning = true;
                                btScanProc.running = true;
                            }
                        }
                    }
                }

                // 3. Kasa (Downloads Trapdoor)
                Rectangle {
                    id: vaultCard
                    property bool isOpen: false
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    radius: 14
                    color: isOpen ? Qt.rgba(0.651, 0.890, 0.631, 0.20) : Colors.surface0
                    border.color: isOpen ? Colors.green : Colors.surface1
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: vaultCard.isOpen ? "󰛉" : "󰌾"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 20
                            color: vaultCard.isOpen ? Colors.green : Colors.text
                            Layout.alignment: Qt.AlignVCenter
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Kasa"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: Colors.text
                            }
                            Text {
                                text: vaultCard.isOpen ? "Açık" : "Kilitli"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                                color: vaultCard.isOpen ? Colors.green : Colors.subtext
                            }
                        }
                    }

                    Process {
                        id: checkVaultProc
                        command: ["sh", "-c", "[ \"$(stat -c '%U' \"$HOME/.local/share/SecureDownloads\" 2>/dev/null)\" = \"$USER\" ] && echo 'open' || echo 'closed'"]
                        running: false
                        stdout: SplitParser {
                            onRead: data => {
                                vaultCard.isOpen = (data.trim() === "open");
                            }
                        }
                    }

                    TapHandler {
                        onTapped: {
                            Quickshell.execDetached(["dl-toggle"]);
                            vaultTimer.restart();
                        }
                    }
                    Timer {
                        id: vaultTimer
                        interval: 300
                        running: false
                        onTriggered: checkVaultProc.running = true
                    }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                }
            }

            // Alt Satır: Gece Işığı, Mikrofon, DND Mode
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Gece Işığı
                Rectangle {
                    property bool isActive: false
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 12
                    color: isActive ? Qt.rgba(0.980, 0.702, 0.529, 0.20) : Colors.surface0
                    border.color: isActive ? Colors.peach : Colors.surface1
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "󰖔"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; color: parent.parent.isActive ? Colors.peach : Colors.text }
                        Text { text: "Gece Işığı"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.weight: Font.Medium; color: parent.parent.isActive ? Colors.peach : Colors.text }
                    }
                    TapHandler {
                        onTapped: {
                            parent.isActive = !parent.isActive;
                            if (parent.isActive) Quickshell.execDetached(["wlsunset", "-T", "4500"]);
                            else Quickshell.execDetached(["killall", "wlsunset"]);
                        }
                    }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                }

                // Mikrofon
                Rectangle {
                    property bool isMuted: false
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 12
                    color: isMuted ? Qt.rgba(0.953, 0.545, 0.659, 0.20) : Colors.surface0
                    border.color: isMuted ? Colors.red : Colors.surface1
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: parent.parent.isMuted ? "󰍭" : "󰍬"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; color: parent.parent.isMuted ? Colors.red : Colors.text }
                        Text { text: "Mikrofon"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.weight: Font.Medium; color: parent.parent.isMuted ? Colors.red : Colors.text }
                    }
                    TapHandler {
                        onTapped: {
                            parent.isMuted = !parent.isMuted;
                            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
                        }
                    }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                }

                // DND Mode
                Rectangle {
                    property bool dnd: false
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: 12
                    color: dnd ? Qt.rgba(0.796, 0.651, 0.969, 0.20) : Colors.surface0
                    border.color: dnd ? Colors.mauve : Colors.surface1
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: parent.parent.dnd ? "󰂛" : "󰂚"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 16; color: parent.parent.dnd ? Colors.mauve : Colors.text }
                        Text { text: "DND"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11; font.weight: Font.Medium; color: parent.parent.dnd ? Colors.mauve : Colors.text }
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
        }

        // ── 4.1 WI-FI GENİŞLEYEBİLİR ÇEKMECE (DRAWER) ──
        Rectangle {
            id: wifiDrawer
            Layout.fillWidth: true
            visible: root.wifiDrawerOpen
            implicitHeight: root.wifiDrawerOpen ? Math.min(230, wifiCol.implicitHeight + 20) : 0
            radius: 14
            color: Qt.rgba(0.09, 0.09, 0.14, 0.92)
            border.color: Colors.blue
            border.width: 1
            clip: true

            Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            ColumnLayout {
                id: wifiCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Header: Başlık + WiFi On/Off + Yenile Butonu
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Wi-Fi Ağları (" + root.wifiNetworks.length + ")"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: Colors.text
                        Layout.fillWidth: true
                    }

                    // WiFi Aç/Kapat Butonu
                    Rectangle {
                        width: 52; height: 22; radius: 11
                        color: root.wifiEnabled ? Colors.blue : Colors.surface1
                        Text {
                            anchors.centerIn: parent
                            text: root.wifiEnabled ? "Açık" : "Kapalı"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: root.wifiEnabled ? Colors.base : Colors.subtext
                        }
                        TapHandler {
                            onTapped: {
                                if (root.wifiEnabled) Quickshell.execDetached(["nmcli", "radio", "wifi", "off"]);
                                else Quickshell.execDetached(["nmcli", "radio", "wifi", "on"]);
                                root.wifiEnabled = !root.wifiEnabled;
                                wifiScanTimer.restart();
                            }
                        }
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                    }

                    // Yenile Butonu
                    Rectangle {
                        width: 24; height: 22; radius: 11
                        color: "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            color: root.wifiScanning ? Colors.blue : Colors.subtext
                            RotationAnimation on rotation {
                                running: root.wifiScanning
                                loops: Animation.Infinite
                                from: 0; to: 360; duration: 800
                            }
                        }
                        TapHandler {
                            onTapped: {
                                root.wifiScanning = true;
                                wifiScanProc.running = true;
                            }
                        }
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                    }
                }

                // Ağ Listesi
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: netCol.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: netCol
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: root.wifiNetworks.slice(0, 6)
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: (root.selectedSsid === modelData.ssid && !modelData.inUse) ? 72 : 36
                                radius: 8
                                color: modelData.inUse ? Qt.rgba(0.537, 0.706, 0.980, 0.15)
                                     : (netItemHov.hovered ? Colors.surface1 : "transparent")
                                border.color: modelData.inUse ? Colors.blue : "transparent"
                                border.width: 1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 4

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Text {
                                            text: modelData.signal >= 75 ? "󰤨"
                                                : (modelData.signal >= 50 ? "󰤥"
                                                : (modelData.signal >= 25 ? "󰤢" : "󰤟"))
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 14
                                            color: modelData.inUse ? Colors.blue : Colors.subtext
                                        }

                                        Text {
                                            text: modelData.ssid
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            font.weight: modelData.inUse ? Font.Bold : Font.Normal
                                            color: modelData.inUse ? Colors.blue : Colors.text
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: "󰌾"
                                            visible: modelData.isSecure
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 11
                                            color: Colors.subtext
                                        }

                                        Rectangle {
                                            implicitWidth: statusText.implicitWidth + 14
                                            implicitHeight: 22
                                            radius: 11
                                            color: modelData.inUse ? Colors.green : (btnHov.hovered ? Colors.blue : Colors.surface2)

                                            Text {
                                                id: statusText
                                                anchors.centerIn: parent
                                                text: modelData.inUse ? "Bağlı" : "Bağlan"
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                                color: (modelData.inUse || btnHov.hovered) ? Colors.base : Colors.text
                                            }

                                            TapHandler {
                                                onTapped: {
                                                    if (modelData.inUse) {
                                                        Quickshell.execDetached(["nmcli", "dev", "disconnect", "wlp9s0"]);
                                                        wifiScanTimer.restart();
                                                    } else if (!modelData.isSecure) {
                                                        Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", modelData.ssid]);
                                                        wifiScanTimer.restart();
                                                    } else {
                                                        root.selectedSsid = (root.selectedSsid === modelData.ssid ? "" : modelData.ssid);
                                                    }
                                                }
                                            }
                                            HoverHandler { id: btnHov; cursorShape: Qt.PointingHandCursor }
                                        }
                                    }

                                    // Parola Giriş Alanı
                                    RowLayout {
                                        visible: root.selectedSsid === modelData.ssid && !modelData.inUse
                                        Layout.fillWidth: true
                                        spacing: 6

                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 24
                                            radius: 6
                                            color: Colors.crust
                                            border.color: pwdInput.activeFocus ? Colors.blue : Colors.surface2
                                            border.width: 1

                                            TextInput {
                                                id: pwdInput
                                                anchors.fill: parent
                                                anchors.leftMargin: 8
                                                anchors.rightMargin: 8
                                                verticalAlignment: TextInput.AlignVCenter
                                                echoMode: TextInput.Password
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                color: Colors.text
                                                onAccepted: {
                                                    if (text.length > 0) {
                                                        Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", modelData.ssid, "password", text]);
                                                        root.selectedSsid = "";
                                                        wifiScanTimer.restart();
                                                    }
                                                }
                                            }
                                        }

                                        Rectangle {
                                            width: 50; height: 24; radius: 6
                                            color: Colors.blue
                                            Text {
                                                anchors.centerIn: parent
                                                text: "Bağlan"
                                                font.family: "JetBrainsMono Nerd Font"
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                                color: Colors.base
                                            }
                                            TapHandler {
                                                onTapped: {
                                                    if (pwdInput.text.length > 0) {
                                                        Quickshell.execDetached(["nmcli", "dev", "wifi", "connect", modelData.ssid, "password", pwdInput.text]);
                                                        root.selectedSsid = "";
                                                        wifiScanTimer.restart();
                                                    }
                                                }
                                            }
                                            HoverHandler { cursorShape: Qt.PointingHandCursor }
                                        }
                                    }
                                }

                                HoverHandler { id: netItemHov }
                            }
                        }

                        Text {
                            visible: root.wifiNetworks.length === 0
                            text: root.wifiScanning ? "Ağlar taranıyor..." : "Kullanılabilir ağ bulunamadı."
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: Colors.subtext
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 10
                        }
                    }
                }
            }
        }

        // ── 4.2 BLUETOOTH GENİŞLEYEBİLİR ÇEKMECE (DRAWER) ──
        Rectangle {
            id: btDrawer
            Layout.fillWidth: true
            visible: root.btDrawerOpen
            implicitHeight: root.btDrawerOpen ? Math.min(220, btCol.implicitHeight + 20) : 0
            radius: 14
            color: Qt.rgba(0.09, 0.09, 0.14, 0.92)
            border.color: Colors.mauve
            border.width: 1
            clip: true

            Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

            ColumnLayout {
                id: btCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Header: Başlık + BT On/Off + Cihaz Tara
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Bluetooth Cihazları (" + root.btDevices.length + ")"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: Colors.text
                        Layout.fillWidth: true
                    }

                    // BT Aç/Kapat Butonu
                    Rectangle {
                        width: 52; height: 22; radius: 11
                        color: root.btEnabled ? Colors.mauve : Colors.surface1
                        Text {
                            anchors.centerIn: parent
                            text: root.btEnabled ? "Açık" : "Kapalı"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: root.btEnabled ? Colors.base : Colors.subtext
                        }
                        TapHandler {
                            onTapped: {
                                if (root.btEnabled) Quickshell.execDetached(["bluetoothctl", "power", "off"]);
                                else Quickshell.execDetached(["bluetoothctl", "power", "on"]);
                                root.btEnabled = !root.btEnabled;
                                btScanTimer.restart();
                            }
                        }
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                    }

                    // Yenile / Tara Butonu
                    Rectangle {
                        width: 24; height: 22; radius: 11
                        color: "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            color: root.btScanning ? Colors.mauve : Colors.subtext
                            RotationAnimation on rotation {
                                running: root.btScanning
                                loops: Animation.Infinite
                                from: 0; to: 360; duration: 800
                            }
                        }
                        TapHandler {
                            onTapped: {
                                root.btScanning = true;
                                btScanProc.running = true;
                            }
                        }
                        HoverHandler { cursorShape: Qt.PointingHandCursor }
                    }
                }

                // Cihaz Listesi
                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: devCol.implicitHeight
                    clip: true

                    ColumnLayout {
                        id: devCol
                        width: parent.width
                        spacing: 6

                        Repeater {
                            model: root.btDevices
                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 36
                                radius: 8
                                color: modelData.connected ? Qt.rgba(0.796, 0.651, 0.969, 0.15)
                                     : (devItemHov.hovered ? Colors.surface1 : "transparent")
                                border.color: modelData.connected ? Colors.mauve : "transparent"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    spacing: 8

                                    Text {
                                        text: {
                                            let n = (modelData.name || "").toLowerCase();
                                            if (n.includes("head") || n.includes("buds") || n.includes("airpods") || n.includes("wh-") || n.includes("kulak")) return "󰋋";
                                            if (n.includes("mouse") || n.includes("fare")) return "󰍽";
                                            if (n.includes("keyboard") || n.includes("klavye")) return "󰌌";
                                            if (n.includes("phone") || n.includes("pro") || n.includes("samsung") || n.includes("iphone") || n.includes("redmi") || n.includes("poco")) return "󰏲";
                                            return "󰂯";
                                        }
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 14
                                        color: modelData.connected ? Colors.mauve : Colors.subtext
                                    }

                                    Text {
                                        text: modelData.name
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        font.weight: modelData.connected ? Font.Bold : Font.Normal
                                        color: modelData.connected ? Colors.mauve : Colors.text
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        implicitWidth: btBtnText.implicitWidth + 14
                                        implicitHeight: 22
                                        radius: 11
                                        color: modelData.connected ? Colors.green : (btBtnHov.hovered ? Colors.mauve : Colors.surface2)

                                        Text {
                                            id: btBtnText
                                            anchors.centerIn: parent
                                            text: modelData.connected ? "Bağlı" : "Bağlan"
                                            font.family: "JetBrainsMono Nerd Font"
                                            font.pixelSize: 10
                                            font.weight: Font.Bold
                                            color: (modelData.connected || btBtnHov.hovered) ? Colors.base : Colors.text
                                        }

                                        TapHandler {
                                            onTapped: {
                                                if (modelData.connected) {
                                                    Quickshell.execDetached(["bluetoothctl", "disconnect", modelData.mac]);
                                                } else {
                                                    Quickshell.execDetached(["bluetoothctl", "connect", modelData.mac]);
                                                }
                                                btScanTimer.restart();
                                            }
                                        }
                                        HoverHandler { id: btBtnHov; cursorShape: Qt.PointingHandCursor }
                                    }
                                }

                                HoverHandler { id: devItemHov }
                            }
                        }

                        Text {
                            visible: root.btDevices.length === 0
                            text: root.btScanning ? "Cihazlar taranıyor..." : "Kayıtlı bluetooth cihazı yok."
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: Colors.subtext
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 10
                        }
                    }
                }
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
