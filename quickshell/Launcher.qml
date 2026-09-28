import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// ═══════════════════════════════════════════════════════════════════
// Sovereign Launcher — Native Quickshell App Launcher + Clipboard
// Fuzzy search, keyboard navigation, glassmorphism
// ═══════════════════════════════════════════════════════════════════
PanelWindow {
    id: root
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "sovereign-launcher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors { top: true; bottom: true; left: true; right: true }
    visible: GlobalStates.launcherOpen || GlobalStates.clipboardOpen
    color:   "transparent"

    // ── State ────────────────────────────────────────────────────────
    readonly property bool isClipboard: GlobalStates.clipboardOpen && !GlobalStates.launcherOpen
    property var filteredApps: []
    property var clipboardItems: []
    property int selectedIndex: 0

    onVisibleChanged: {
        if (visible) {
            searchField.text = ""
            selectedIndex = 0
            searchField.forceActiveFocus()
            if (isClipboard) clipboardProc.running = true
            else updateAppFilter("")
        }
    }

    // ── App Filtering ────────────────────────────────────────────────
    function updateAppFilter(query) {
        let rawVals = DesktopEntries.applications ? DesktopEntries.applications.values : null
        let entries = []
        if (rawVals) {
            for (let i = 0; i < rawVals.length; i++) {
                let e = rawVals[i]
                if (e && e.name && !e.noDisplay) entries.push(e)
            }
        }
        if (query.length === 0) {
            // Popüler uygulamaları üstte göster (alfabetik)
            entries.sort((a, b) => (a.name || "").localeCompare(b.name || ""))
            filteredApps = entries.slice(0, 8)
        } else {
            let q = query.toLowerCase()
            let scored = []
            for (let i = 0; i < entries.length; i++) {
                let e = entries[i]
                let name = (e.name || "").toLowerCase()
                let generic = (e.genericName || "").toLowerCase()
                let comment = (e.comment || "").toLowerCase()
                let score = 0

                // Exact prefix match — en yüksek skor
                if (name.startsWith(q)) score = 100
                else if (name.includes(q)) score = 80
                else if (generic.includes(q)) score = 60
                else if (comment.includes(q)) score = 40
                else {
                    // Fuzzy: karakter sırası eşleştirmesi
                    let fi = 0
                    for (let ci = 0; ci < name.length && fi < q.length; ci++) {
                        if (name[ci] === q[fi]) fi++
                    }
                    if (fi === q.length) score = 20
                }

                if (score > 0) scored.push({ entry: e, score: score })
            }
            scored.sort((a, b) => b.score - a.score)
            filteredApps = scored.slice(0, 8).map(s => s.entry)
        }
        selectedIndex = 0
    }

    // ── Clipboard Data ───────────────────────────────────────────────
    Process {
        id: clipboardProc
        command: ["cliphist", "list"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                let items = root.clipboardItems
                let line = data.trim()
                if (line.length > 0) items.push(line)
                root.clipboardItems = items
            }
        }
        onRunningChanged: {
            if (running) root.clipboardItems = []
        }
    }

    Process {
        id: clipboardDecodeProc
        command: ["sh", "-c", ""]
        running: false
    }

    function selectClipboardItem(item) {
        clipboardDecodeProc.command = ["sh", "-c", "echo '" + item.replace(/'/g, "'\\''") + "' | cliphist decode | wl-copy"]
        clipboardDecodeProc.running = true
        closeLauncher()
    }

    function launchApp(entry) {
        entry.execute()
        closeLauncher()
    }

    function closeLauncher() {
        GlobalStates.launcherOpen = false
        GlobalStates.clipboardOpen = false
    }

    // ── Backdrop (tıkla kapat) ───────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)

        Behavior on opacity { NumberAnimation { duration: 200 } }

        TapHandler { onTapped: root.closeLauncher() }
    }

    // ── Launcher Container ───────────────────────────────────────────
    Rectangle {
        id: container
        anchors.centerIn: parent
        width:  500
        height: contentCol.implicitHeight + 32
        radius: 20
        color:  Qt.rgba(0.075, 0.075, 0.118, 0.88)
        border.color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1

        // Glow efekti
        layer.enabled: true
        layer.effect: null

        // Giriş animasyonu
        scale: root.visible ? 1.0 : 0.85
        opacity: root.visible ? 1.0 : 0.0
        Behavior on scale   { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
        Behavior on opacity { NumberAnimation { duration: 200 } }

        ColumnLayout {
            id: contentCol
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 12

            // ── Header ───────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: root.isClipboard ? "󰅍" : "󰍉"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    color: root.isClipboard ? Colors.yellow : Colors.cyan
                }

                // Search Input
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: 12
                    color: Qt.rgba(0.118, 0.118, 0.180, 0.65)
                    border.color: searchField.activeFocus
                        ? Qt.rgba(0.490, 0.812, 1.0, 0.45)
                        : Qt.rgba(1, 1, 1, 0.07)
                    border.width: 1

                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    TextInput {
                        id: searchField
                        anchors {
                            fill: parent
                            leftMargin: 14
                            rightMargin: 14
                        }
                        verticalAlignment: TextInput.AlignVCenter
                        font.family:    "Inter"
                        font.pixelSize: 15
                        color:          Colors.text
                        clip:           true
                        selectByMouse:  true

                        onTextChanged: {
                            if (!root.isClipboard) root.updateAppFilter(text)
                        }

                        // Keyboard navigation
                        Keys.onPressed: event => {
                            let maxIdx = root.isClipboard
                                ? Math.min(root.clipboardItems.length, 8) - 1
                                : root.filteredApps.length - 1

                            if (event.key === Qt.Key_Down) {
                                root.selectedIndex = Math.min(root.selectedIndex + 1, maxIdx)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up) {
                                root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (root.isClipboard) {
                                    if (root.selectedIndex < root.clipboardItems.length)
                                        root.selectClipboardItem(root.clipboardItems[root.selectedIndex])
                                } else {
                                    if (root.selectedIndex < root.filteredApps.length)
                                        root.launchApp(root.filteredApps[root.selectedIndex])
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Escape) {
                                root.closeLauncher()
                                event.accepted = true
                            }
                        }
                    }

                    // Placeholder
                    Text {
                        anchors {
                            left: parent.left; leftMargin: 14
                            verticalCenter: parent.verticalCenter
                        }
                        visible: searchField.text.length === 0
                        text:    root.isClipboard ? "Clipboard'da ara..." : "Uygulama ara..."
                        font.family:    "Inter"
                        font.pixelSize: 15
                        color:          Colors.overlay0
                    }
                }
            }

            // ── Sonuç Listesi ────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                // App mode
                Repeater {
                    model: root.isClipboard ? 0 : root.filteredApps.length
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        radius: 12
                        color: {
                            if (index === root.selectedIndex) return Qt.rgba(0.490, 0.812, 1.0, 0.12)
                            if (itemHover.hovered) return Qt.rgba(1, 1, 1, 0.05)
                            return "transparent"
                        }
                        border.color: index === root.selectedIndex
                            ? Qt.rgba(0.490, 0.812, 1.0, 0.25) : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }

                        readonly property var entry: root.filteredApps[index]

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 12
                                rightMargin: 12
                            }
                            spacing: 12

                            // App Icon
                            Image {
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                                source: entry ? ("image://icon/" + (entry.icon || "application-x-executable")) : ""
                                sourceSize: Qt.size(28, 28)
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    Layout.fillWidth: true
                                    text: entry ? (entry.name || "") : ""
                                    font.family: "Inter"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: Colors.text
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: text.length > 0
                                    text: entry ? (entry.genericName || entry.comment || "") : ""
                                    font.family: "Inter"
                                    font.pixelSize: 11
                                    color: Colors.overlay0
                                    elide: Text.ElideRight
                                }
                            }
                        }

                        HoverHandler { id: itemHover }
                        TapHandler {
                            onTapped: {
                                if (entry) root.launchApp(entry)
                            }
                        }
                    }
                }

                // Clipboard mode
                Repeater {
                    model: root.isClipboard ? Math.min(root.clipboardItems.length, 8) : 0
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: 12
                        color: {
                            if (index === root.selectedIndex) return Qt.rgba(0.976, 0.886, 0.686, 0.12)
                            if (clipHover.hovered) return Qt.rgba(1, 1, 1, 0.05)
                            return "transparent"
                        }
                        border.color: index === root.selectedIndex
                            ? Qt.rgba(0.976, 0.886, 0.686, 0.25) : "transparent"
                        border.width: 1

                        Behavior on color { ColorAnimation { duration: 100 } }

                        readonly property string clipText: root.clipboardItems[index] || ""

                        RowLayout {
                            anchors {
                                fill: parent
                                leftMargin: 12
                                rightMargin: 12
                            }
                            spacing: 10

                            Text {
                                text: "󰆏"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 16
                                color: Colors.yellow
                            }

                            Text {
                                Layout.fillWidth: true
                                text: {
                                    // cliphist format: "ID\tContent"
                                    let parts = clipText.split("\t")
                                    return parts.length > 1 ? parts.slice(1).join("\t") : clipText
                                }
                                font.family: "Inter"
                                font.pixelSize: 13
                                color: Colors.text
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }

                        HoverHandler { id: clipHover }
                        TapHandler {
                            onTapped: root.selectClipboardItem(clipText)
                        }
                    }
                }

                // Empty state
                Item {
                    Layout.fillWidth: true
                    height: 80
                    visible: (root.isClipboard && root.clipboardItems.length === 0)
                             || (!root.isClipboard && root.filteredApps.length === 0)

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.isClipboard ? "󰅍" : "󰍉"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 28
                            color: Colors.overlay0
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.isClipboard ? "Clipboard boş" : "Sonuç bulunamadı"
                            font.family: "Inter"
                            font.pixelSize: 13
                            color: Colors.overlay0
                        }
                    }
                }
            }

            // ── Footer (kısayol ipuçları) ────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Item { Layout.fillWidth: true }

                Row {
                    spacing: 6
                    Rectangle {
                        width: 20; height: 18; radius: 4
                        color: Qt.rgba(1, 1, 1, 0.06)
                        Text { anchors.centerIn: parent; text: "↑"; font.pixelSize: 10; color: Colors.overlay1 }
                    }
                    Rectangle {
                        width: 20; height: 18; radius: 4
                        color: Qt.rgba(1, 1, 1, 0.06)
                        Text { anchors.centerIn: parent; text: "↓"; font.pixelSize: 10; color: Colors.overlay1 }
                    }
                    Text { text: "Seç"; font.family: "Inter"; font.pixelSize: 11; color: Colors.overlay0; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 6
                    Rectangle {
                        width: 32; height: 18; radius: 4
                        color: Qt.rgba(1, 1, 1, 0.06)
                        Text { anchors.centerIn: parent; text: "⏎"; font.pixelSize: 10; color: Colors.overlay1 }
                    }
                    Text { text: "Başlat"; font.family: "Inter"; font.pixelSize: 11; color: Colors.overlay0; anchors.verticalCenter: parent.verticalCenter }
                }

                Row {
                    spacing: 6
                    Rectangle {
                        width: 32; height: 18; radius: 4
                        color: Qt.rgba(1, 1, 1, 0.06)
                        Text { anchors.centerIn: parent; text: "Esc"; font.pixelSize: 9; color: Colors.overlay1 }
                    }
                    Text { text: "Kapat"; font.family: "Inter"; font.pixelSize: 11; color: Colors.overlay0; anchors.verticalCenter: parent.verticalCenter }
                }
            }
        }
    }
}
