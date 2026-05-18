// Sovereign Clock — Tıklanabilir saat/tarih toggle
import QtQuick
import Quickshell

Rectangle {
    id: root

    property bool showDate: false

    implicitHeight: 44
    implicitWidth:  timeText.implicitWidth + 44
    radius:         14
    color:          Colors.glass
    border.color:   hovered.containsMouse
        ? Qt.rgba(0.980, 0.702, 0.529, 0.45)
        : Qt.rgba(0.980, 0.702, 0.529, 0.20)
    border.width: 1

    Behavior on border.color { ColorAnimation { duration: 150 } }

    Text {
        id: timeText
        anchors.centerIn: parent
        text:           "  " + Qt.formatDateTime(new Date(), "hh:mm")
        font.pixelSize: 15
        font.weight:    Font.Black
        color:          Colors.peach
        letterSpacing:  0.5
    }

    // Dakikada bir güncelle
    Timer {
        interval: 1000
        running:  !root.showDate
        repeat:   true
        onTriggered: timeText.text = "  " + Qt.formatDateTime(new Date(), "hh:mm")
    }

    // Tıklayınca saat ↔ tarih toggle
    TapHandler {
        onTapped: {
            root.showDate = !root.showDate
            timeText.text = root.showDate
                ? Qt.formatDateTime(new Date(), "  ddd, d MMM")
                : "  " + Qt.formatDateTime(new Date(), "hh:mm")
        }
    }

    HoverHandler { id: hovered }
}
