import QtQuick
import Quickshell

// Ses gösterim bileşeni — tüm iş mantığı AudioService'te
Rectangle {
    id: root

    implicitHeight: Appearance.size.widgetH
    implicitWidth:  row.implicitWidth + 20
    radius:         Appearance.size.radius
    color:          Qt.rgba(0.118, 0.118, 0.180, 0.65)
    border.color:   Qt.rgba(0.976, 0.886, 0.686, AudioService.muted ? 0.08 : 0.18)
    border.width:   1
    Behavior on border.color { ColorAnimation { duration: Appearance.anim.fast.dur } }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: AudioService.muted          ? "󰝟"
                : AudioService.volume < 30    ? "󰕿"
                : AudioService.volume < 70    ? "󰖀"
                :                               "󰕾"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: Appearance.size.iconSize
            color:          AudioService.muted ? "#45475a" : "#f9e2af"
            Behavior on color { ColorAnimation { duration: Appearance.anim.fast.dur } }
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text:           AudioService.volume + "%"
            font.family:    "JetBrainsMono Nerd Font"
            font.pixelSize: Appearance.size.textSize
            font.weight:    Font.DemiBold
            color:          AudioService.muted ? "#6c7086" : "#f9e2af"
            Behavior on color { ColorAnimation { duration: Appearance.anim.fast.dur } }
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    TapHandler { onTapped: AudioService.openMixer() }
    MouseArea {
        anchors.fill:    parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) AudioService.raiseVolume()
            else                         AudioService.lowerVolume()
        }
    }
}
