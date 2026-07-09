import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "sovereign-overview"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors { top: true; bottom: true; left: true; right: true }

    visible: GlobalStates.overviewOpen
    color: Qt.rgba(0.094, 0.094, 0.137, 0.85)

    property var clients: []

    onVisibleChanged: {
        if (visible) {
            refreshProc.running = true
        } else {
            root.clients = []
        }
    }

    Process {
        id: refreshProc
        command: ["sh", "-c", "hyprctl clients -j | jq -c '.'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data)
                    // Filtreleme: workspace id > 0 olan ve map edilmiş pencereler
                    root.clients = parsed.filter(c => c.mapped && c.workspace.id > 0)
                } catch(e) {
                    console.log("JSON Parse Error: " + e)
                }
            }
        }
    }

    // Ekranın herhangi bir yerine tıklayınca overview'ı kapat
    TapHandler {
        onTapped: GlobalStates.overviewOpen = false
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Mission Control"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 24
            font.weight: Font.Bold
            color: "#cdd6f4"
        }

        Flow {
            Layout.preferredWidth: 1000
            spacing: 20
            
            Repeater {
                model: root.clients

                delegate: Rectangle {
                    required property var modelData
                    
                    width: 240
                    height: 160
                    radius: Appearance.size.radius
                    color: Qt.rgba(0.118, 0.118, 0.180, 0.9)
                    border.color: Qt.rgba(0.537, 0.706, 0.980, 0.3)
                    border.width: 1

                    // Hover efekti
                    HoverHandler { id: hh }
                    scale: hh.hovered ? 1.05 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    border.color: hh.hovered ? "#89b4fa" : Qt.rgba(0.537, 0.706, 0.980, 0.3)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        Text {
                            text: "Workspace " + modelData.workspace.id
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 10
                            color: "#a6adc8"
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: modelData.class
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: "#89b4fa"
                            Layout.alignment: Qt.AlignHCenter
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            text: modelData.title
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: "#cdd6f4"
                            Layout.alignment: Qt.AlignHCenter
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    TapHandler {
                        onTapped: {
                            Quickshell.execDetached(["hyprctl", "dispatch", "focuswindow", "address:" + modelData.address])
                            GlobalStates.overviewOpen = false
                        }
                    }
                }
            }
        }
    }
}
