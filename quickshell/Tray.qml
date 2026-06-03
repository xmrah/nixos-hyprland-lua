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
                id: trayDelegate
                required property SystemTrayItem modelData
                width: 16; height: 44

                Image {
                    anchors.centerIn: parent
                    source:  trayDelegate.modelData.icon
                    width:   16
                    height:  16
                    smooth:  true
                    fillMode: Image.PreserveAspectFit
                }

                QsMenuAnchor {
                    id: contextMenu
                    menu: trayDelegate.modelData.menu
                    anchor.window: trayDelegate.QsWindow.window
                    anchor.rect.x: trayDelegate.mapToGlobal(0, 0).x
                    anchor.rect.y: trayDelegate.mapToGlobal(0, trayDelegate.height).y
                    anchor.rect.width:  trayDelegate.width
                    anchor.rect.height: 0
                }

                TapHandler {
                    onTapped:        trayDelegate.modelData.activate()
                    acceptedButtons: Qt.LeftButton
                }
                TapHandler {
                    onTapped: {
                        if (trayDelegate.modelData.menu)
                            contextMenu.open()
                        else
                            trayDelegate.modelData.secondaryActivate()
                    }
                    acceptedButtons: Qt.RightButton
                }
            }
        }
    }
}
