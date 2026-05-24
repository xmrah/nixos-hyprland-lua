import QtQuick
import Quickshell

// Parlaklık gösterim bileşeni — tüm iş mantığı BrightnessService'te
Rectangle {
    id: root

    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 20
    radius:         Appearance.size.radius
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(0.980, 0.898, 0.686, 0.18)
    border.width:   1
    Behavior on border.color { ColorAnimation { duration: Appearance.anim.fast.dur } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: BrightnessService.brightness < 30 ? "󰃞"
                : BrightnessService.brightness < 70 ? "󰃟"
                :                                      "󰃠"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: Appearance.size.iconSize
            color:          "#f9e2af"
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text:           BrightnessService.brightness + "%"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: Appearance.size.textSize
            font.weight:    Font.DemiBold
            color:          "#f9e2af"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        anchors.fill:    parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) BrightnessService.increase()
            else                         BrightnessService.decrease()
        }
    }
}
