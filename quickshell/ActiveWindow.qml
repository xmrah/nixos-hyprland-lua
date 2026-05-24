import QtQuick
import Quickshell
import Quickshell.Io

// Aktif pencere başlığı — hyprctl activewindow, 500ms poll
// Tıkla → aktif pencereyi kapat (killactive)
Rectangle {
    id: root

    property string windowTitle: ""
    readonly property bool hasContent: windowTitle.length > 0

    visible:        hasContent
    implicitHeight: Appearance.size.widgetH
    implicitWidth:  titleText.implicitWidth + 20
    radius:         Appearance.size.radiusSm
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(0.537, 0.706, 0.980, 0.18)
    border.width:   1

    Process { id: killProc; command: ["hyprctl", "dispatch", "killactive"]; running: false }

    Process {
        id: titleProc
        command: ["sh", "-c", "hyprctl activewindow 2>/dev/null | sed -n 's/^\\s*title: //p' | head -1"]
        running: false
        stdout: SplitParser {
            onRead: data => root.windowTitle = data.trim()
        }
        onExited: function(exitCode) {
            if (exitCode !== 0) root.windowTitle = ""
        }
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!titleProc.running) titleProc.running = true
    }

    Text {
        id: titleText
        anchors.centerIn: parent
        property string full: root.windowTitle
        text:           full.length > 40 ? full.substring(0, 40) + "\u2026" : full
        font.family:    "JetBrainsMono Nerd Font"
        font.pixelSize: Appearance.size.textSize
        font.weight:    Font.DemiBold
        color:          "#89b4fa"
    }

    TapHandler { onTapped: if (!killProc.running) killProc.running = true }
}
