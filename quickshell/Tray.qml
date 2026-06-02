// Sovereign Tray — Sistem tepsisi (StatusNotifier / AppIndicator)
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Rectangle {
    id: root

    implicitHeight: 44
    implicitWidth:  trayItems.count > 0 ? (trayItems.count * 24) + 20 : 0
    visible:        trayItems.count > 0
    radius:         14
    color:          Colors.glass
    border.color:   Colors.glassBorder
    border.width:   1

    Row {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            id: trayItems
            model: SystemTray.items

            delegate: Item {
                required property SystemTrayItem modelData
                width: 16; height: 44

                Image {
                    anchors.centerIn: parent
                    source:  parent.modelData.icon
                    width:   16
                    height:  16
                    smooth:  true
                    fillMode: Image.PreserveAspectFit
                }

                TapHandler {
                    onTapped:            parent.modelData.activate()
                    acceptedButtons:     Qt.LeftButton
                }
                TapHandler {
                    onTapped:            parent.modelData.secondaryActivate()
                    acceptedButtons:     Qt.RightButton
                }
            }
        }
    }
}
