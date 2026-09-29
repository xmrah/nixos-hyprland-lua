pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// ═══════════════════════════════════════════════════════════════════
// Sovereign Notification Service — Tek DBus Bildirim Yöneticisi
// Singleton: NotificationServer tek bir yerden yönetilir
// ═══════════════════════════════════════════════════════════════════
Singleton {
    id: root

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notif => {
            let items = root.toastList
            items.unshift({
                id: notif.id,
                app: notif.appName || "System",
                title: notif.summary || "",
                body: notif.body || "",
                icon: notif.appIcon || "",
                time: new Date(),
                notif: notif
            })
            if (items.length > 3) {
                items.pop()
            }
            root.toastList = [...items]
        }
    }

    readonly property alias server: server
    readonly property alias trackedNotifications: server.trackedNotifications
    readonly property int count: server.trackedNotifications && server.trackedNotifications.values
        ? server.trackedNotifications.values.length : 0

    property var toastList: []

    // Toast popup'ı ekrandan kapatır (Bildirim sunucusundan silmez, geçmişte kalır)
    function dismissToast(index) {
        let items = root.toastList
        if (index >= 0 && index < items.length) {
            items.splice(index, 1)
            root.toastList = [...items]
        }
    }

    function clearAll() {
        if (server.trackedNotifications && server.trackedNotifications.values) {
            let list = [...server.trackedNotifications.values]
            for (let i = 0; i < list.length; i++) {
                if (list[i] && typeof list[i].dismiss === "function") {
                    try { list[i].dismiss() } catch(e) {}
                }
            }
        }
        root.toastList = []
    }
}
