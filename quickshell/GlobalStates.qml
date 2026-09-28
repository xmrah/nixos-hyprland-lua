pragma Singleton
import QtQuick

// ═══════════════════════════════════════════════════════════════════
// Sovereign Global States — Tüm bileşenler arası paylaşılan durum
// ═══════════════════════════════════════════════════════════════════
QtObject {
    // ── Panel Durumları ──────────────────────────────────────────────
    property bool dashboardOpen: false
    property bool overviewOpen: false
    property bool launcherOpen: false
    property bool clipboardOpen: false
    property bool notificationPanelOpen: false
    property bool powerMenuOpen: false

    // ── Bar Durumu ───────────────────────────────────────────────────
    property bool barVisible: true

    // ── Bildirim ─────────────────────────────────────────────────────
    readonly property int notificationCount: NotificationService.count

    // ── Modlar ───────────────────────────────────────────────────────
    property bool zenMode: false
}
