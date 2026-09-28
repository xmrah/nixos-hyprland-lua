import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// ═══════════════════════════════════════════════════════════════════
// Sovereign Notification Panel — Bildirim geçmişi (SUPER+N)
// Sağ kenar, Dashboard'un altında açılır
// NotificationService singleton'ından beslenir
// ═══════════════════════════════════════════════════════════════════
PanelWindow {
    id: root
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "sovereign-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    anchors { top: true; right: true; bottom: true }
    margins.top:    Appearance.size.barH + Appearance.size.marginTop + 10
    margins.right:  Appearance.size.marginSide
    margins.bottom: Appearance.size.marginSide

    visible: GlobalStates.notificationPanelOpen
    color:   "transparent"

    implicitWidth: 400

    Rectangle {
        anchors.fill: parent
        radius: 20
        color:  Qt.rgba(0.075, 0.075, 0.118, 0.92)
        border.color: Qt.rgba(1, 1, 1, 0.06)
        border.width: 1

        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 12

            // ── Header ───────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "󰂚"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    color: Colors.cyan
                }

                Text {
                    Layout.fillWidth: true
                    text: "Bildirimler"
                    font.family: "Inter"
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    color: Colors.text
                    leftPadding: 8
                }

                // Hepsini temizle butonu
                Rectangle {
                    visible: NotificationService.count > 0
                    width: clearRow.implicitWidth + 16
                    height: 28
                    radius: 8
                    color: clearHover.hovered
                        ? Qt.rgba(0.953, 0.545, 0.659, 0.15)
                        : Qt.rgba(1, 1, 1, 0.05)
                    border.color: clearHover.hovered
                        ? Qt.rgba(0.953, 0.545, 0.659, 0.30)
                        : "transparent"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        id: clearRow
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "󰅖"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            color: clearHover.hovered ? Colors.red : Colors.overlay1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Temizle"
                            font.family: "Inter"
                            font.pixelSize: 11
                            color: clearHover.hovered ? Colors.red : Colors.overlay1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    HoverHandler { id: clearHover }
                    TapHandler {
                        onTapped: {
                            NotificationService.clearAll()
                        }
                    }
                }

                // DND Toggle
                Rectangle {
                    width: 28; height: 28; radius: 8
                    color: GlobalStates.zenMode
                        ? Qt.rgba(0.976, 0.886, 0.686, 0.15)
                        : Qt.rgba(1, 1, 1, 0.05)
                    border.color: GlobalStates.zenMode
                        ? Qt.rgba(0.976, 0.886, 0.686, 0.35)
                        : "transparent"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: GlobalStates.zenMode ? "󰂛" : "󰂞"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: GlobalStates.zenMode ? Colors.yellow : Colors.overlay1
                    }

                    TapHandler { onTapped: GlobalStates.zenMode = !GlobalStates.zenMode }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.06)
            }

            // ── Notification List ────────────────────────────────────
            Flickable {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                contentHeight: notifColumn.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                ColumnLayout {
                    id: notifColumn
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: NotificationService.trackedNotifications

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: notifContent.implicitHeight + 20
                            radius: 14
                            color: notifItemHover.hovered
                                ? Qt.rgba(1, 1, 1, 0.05)
                                : Qt.rgba(0.118, 0.118, 0.180, 0.45)
                            border.color: Qt.rgba(1, 1, 1, 0.04)
                            border.width: 1

                            Behavior on color { ColorAnimation { duration: 100 } }

                            readonly property var notif: modelData

                            RowLayout {
                                id: notifContent
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: 10
                                }
                                spacing: 10

                                // App icon
                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    Layout.alignment: Qt.AlignTop
                                    radius: 8
                                    color: Qt.rgba(0.490, 0.812, 1.0, 0.10)

                                    Image {
                                        anchors.centerIn: parent
                                        width: 20; height: 20
                                        source: notif && notif.appIcon
                                            ? ("image://icon/" + notif.appIcon) : ""
                                        sourceSize: Qt.size(20, 20)
                                        visible: notif && notif.appIcon && notif.appIcon.length > 0
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !notif || !notif.appIcon || notif.appIcon.length === 0
                                        text: "󰂚"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 16
                                        color: Colors.cyan
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    RowLayout {
                                        Layout.fillWidth: true

                                        Text {
                                            text: notif ? (notif.appName || "System") : "System"
                                            font.family: "Inter"
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                            color: Colors.cyan
                                        }

                                        Item { Layout.fillWidth: true }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        visible: text.length > 0
                                        text: notif ? (notif.summary || "") : ""
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: Font.DemiBold
                                        color: Colors.text
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        visible: text.length > 0
                                        text: notif ? (notif.body || "") : ""
                                        font.family: "Inter"
                                        font.pixelSize: 12
                                        color: Colors.subtext
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 3
                                        elide: Text.ElideRight
                                    }
                                }

                                // Dismiss
                                Rectangle {
                                    Layout.preferredWidth: 22
                                    Layout.preferredHeight: 22
                                    Layout.alignment: Qt.AlignTop
                                    radius: 6
                                    color: dismissBtnHover.hovered
                                        ? Qt.rgba(0.953, 0.545, 0.659, 0.20)
                                        : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰅖"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 11
                                        color: dismissBtnHover.hovered ? Colors.red : Colors.overlay0
                                    }

                                    HoverHandler { id: dismissBtnHover }
                                    TapHandler { onTapped: if (notif) notif.dismiss() }
                                }
                            }

                            HoverHandler { id: notifItemHover }
                        }
                    }
                }
            }

            // ── Empty State ──────────────────────────────────────────
            Item {
                Layout.fillWidth:  true
                Layout.fillHeight: true
                visible: NotificationService.count === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 16

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "󰂜"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 48
                        color: Colors.surface1
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Bildirim yok"
                        font.family: "Inter"
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        color: Colors.overlay0
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Yeni bildirimler burada görünecek"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: Colors.surface2
                    }
                }
            }
        }
    }
}
