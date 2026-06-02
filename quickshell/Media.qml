import QtQuick
import Quickshell
import Quickshell.Io

// Medya gösterim bileşeni — playerctl MPRIS
// Aktif oynatıcı yoksa görünmez; hover'da ⏮/⏭ genişler
Rectangle {
    id: root

    property string title:     ""
    property string artist:    ""
    property bool   playing:   false
    property bool   hasPlayer: false

    visible:        hasPlayer
    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 20
    radius:         Appearance.size.radiusSm
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(0.796, 0.651, 0.969, 0.18)
    border.width:   1
    clip:           true

    // ── Processes ─────────────────────────────────────────────────────
    Process {
        id: metaProc
        command: ["sh", "-c", "playerctl metadata --format '{{title}}|||{{artist}}' 2>/dev/null"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                const trimmed = data.trim()
                if (!trimmed || trimmed === "|||") return
                const sep      = trimmed.indexOf("|||")
                root.title     = sep >= 0 ? trimmed.substring(0, sep)      : trimmed
                root.artist    = sep >= 0 ? trimmed.substring(sep + 3)     : ""
                root.hasPlayer = true
            }
        }
        onExited: function(exitCode) {
            if (exitCode !== 0) {
                root.hasPlayer = false
                root.title     = ""
                root.artist    = ""
            }
        }
    }

    Process {
        id: statusProc
        command: ["playerctl", "status"]
        running: false
        stdout: SplitParser {
            onRead: data => root.playing = (data.trim() === "Playing")
        }
        onExited: function(exitCode) {
            if (exitCode !== 0) root.playing = false
        }
    }

    Process { id: prevProc;  command: ["playerctl", "previous"];   running: false }
    Process { id: nextProc;  command: ["playerctl", "next"];       running: false }
    Process {
        id: pauseProc
        command: ["playerctl", "play-pause"]
        running: false
        onExited: refresh()
    }

    // ── 2s polling ────────────────────────────────────────────────────
    Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: refresh() }

    function refresh() {
        if (!metaProc.running)   metaProc.running   = true
        if (!statusProc.running) statusProc.running = true
    }

    // ── UI ────────────────────────────────────────────────────────────
    HoverHandler { id: hoverHandler }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 4

        // Prev — hover'da açılır
        Item {
            width:  hoverHandler.hovered ? btnPrev.implicitWidth + 4 : 0
            height: Appearance.size.widgetH
            clip:   true
            Behavior on width { NumberAnimation { duration: Appearance.anim.fast.dur } }

            Text {
                id:             btnPrev
                anchors.centerIn: parent
                text:           "󰒮"
                font.family:    "JetBrainsMono Nerd Font"
                font.pixelSize: Appearance.size.iconSize
                color:          "#cba6f7"
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    if (!prevProc.running) prevProc.running = true
                }
            }
        }

        // Play / Pause
        Text {
            text:           root.playing ? "󰏦" : "󰐊"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: Appearance.size.iconSize
            color:          "#cba6f7"
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: Appearance.anim.fast.dur } }
            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                onClicked:    if (!pauseProc.running) pauseProc.running = true
            }
        }

        // Next — hover'da açılır
        Item {
            width:  hoverHandler.hovered ? btnNext.implicitWidth + 4 : 0
            height: Appearance.size.widgetH
            clip:   true
            Behavior on width { NumberAnimation { duration: Appearance.anim.fast.dur } }

            Text {
                id:             btnNext
                anchors.centerIn: parent
                text:           "󰒭"
                font.family:    "JetBrainsMono Nerd Font"
                font.pixelSize: Appearance.size.iconSize
                color:          "#cba6f7"
                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    if (!nextProc.running) nextProc.running = true
                }
            }
        }

        // Track bilgisi: "Şarkı — Artist" (maks 30 karakter)
        Text {
            property string full: root.artist
                ? root.title + " \u2014 " + root.artist
                : root.title
            text:           full.length > 30 ? full.substring(0, 30) + "\u2026" : full
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: Appearance.size.textSize
            font.weight:    Font.DemiBold
            color:          "#cdd6f4"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
