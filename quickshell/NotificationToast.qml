import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// ═══════════════════════════════════════════════════════════════════
// Sovereign Notification Toast — Sağ üst köşe popup stack
// NotificationService singleton'ından beslenir
// Max 3 toast, otomatik expire, dismiss animasyonlu
// ═══════════════════════════════════════════════════════════════════
PanelWindow {
    id: root
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "sovereign-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors { top: true; right: true }
    margins.top:   Appearance.size.barH + Appearance.size.marginTop + 10
    margins.right: Appearance.size.marginSide

    visible: NotificationService.toastList.length > 0 && !GlobalStates.zenMode
    color:   "transparent"

    implicitWidth:  380
    implicitHeight: toastColumn.implicitHeight

    // ── Toast Stack ──────────────────────────────────────────────────
    ColumnLayout {
        id: toastColumn
        anchors { top: parent.top; right: parent.right }
        width: 380
        spacing: 8

        Repeater {
            id: toastList
            model: NotificationService.toastList.length

            delegate: Rectangle {
                id: toastCard
                Layout.fillWidth: true
                height: cardContent.implicitHeight + 24
                radius: 16
                color:  Qt.rgba(0.075, 0.075, 0.118, 0.92)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1

                // Giriş animasyonu
                opacity: 1.0
                x: 0

                Component.onCompleted: {
                    entryAnim.start()
                }

                NumberAnimation {
                    id: entryAnim
                    target: toastCard
                    property: "x"
                    from: 400
                    to: 0
                    duration: 300
                    easing.type: Easing.OutCubic
                }

                readonly property var toastData: NotificationService.toastList[index] || {}

                // Auto-expire timer
                Timer {
                    interval: {
                        let item = toastCard.toastData
                        return item && item.notif && item.notif.expireTimeout > 0
                            ? item.notif.expireTimeout
                            : 5000
                    }
                    running: true
                    onTriggered: NotificationService.dismissToast(index)
                }

                RowLayout {
                    id: cardContent
                    anchors {
                        fill: parent
                        margins: 12
                    }
                    spacing: 12

                    // App icon
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 10
                        color: Qt.rgba(0.490, 0.812, 1.0, 0.12)

                        Image {
                            anchors.centerIn: parent
                            width: 22; height: 22
                            source: toastCard.toastData.icon
                                ? ("image://icon/" + toastCard.toastData.icon)
                                : ""
                            sourceSize: Qt.size(22, 22)
                            visible: toastCard.toastData.icon && toastCard.toastData.icon.length > 0
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: !toastCard.toastData.icon || toastCard.toastData.icon.length === 0
                            text: "󰂚"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 18
                            color: Colors.cyan
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        // App name + time
                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                Layout.fillWidth: true
                                text: toastCard.toastData.app || "System"
                                font.family: "Inter"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: Colors.cyan
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "şimdi"
                                font.family: "Inter"
                                font.pixelSize: 10
                                color: Colors.overlay0
                            }
                        }

                        // Title
                        Text {
                            Layout.fillWidth: true
                            visible: text.length > 0
                            text: toastCard.toastData.title || ""
                            font.family: "Inter"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: Colors.text
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        // Body
                        Text {
                            Layout.fillWidth: true
                            visible: text.length > 0
                            text: toastCard.toastData.body || ""
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: Colors.subtext
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                        }
                    }

                    // Dismiss button
                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignTop
                        radius: 8
                        color: dismissHover.hovered
                            ? Qt.rgba(0.953, 0.545, 0.659, 0.20)
                            : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            color: dismissHover.hovered ? Colors.red : Colors.overlay0
                        }

                        HoverHandler { id: dismissHover }
                        TapHandler { onTapped: NotificationService.dismissToast(index) }
                    }
                }
            }
        }
    }
}
