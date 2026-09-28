//@ pragma UseQApplication
import Quickshell
import Quickshell.Io

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }

    Dashboard {}
    Overview {}
    Launcher {}
    NotificationToast {}
    NotificationPanel {}
    PowerOverlay {}

    // ── IPC Handlers ─────────────────────────────────────────────────
    IpcHandler {
        target: "overview"
        function toggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen
        }
    }

    IpcHandler {
        target: "dashboard"
        function toggle() {
            GlobalStates.dashboardOpen = !GlobalStates.dashboardOpen
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle() {
            GlobalStates.launcherOpen = !GlobalStates.launcherOpen
            if (GlobalStates.launcherOpen) GlobalStates.clipboardOpen = false
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle() {
            GlobalStates.clipboardOpen = !GlobalStates.clipboardOpen
            if (GlobalStates.clipboardOpen) GlobalStates.launcherOpen = false
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle() {
            GlobalStates.notificationPanelOpen = !GlobalStates.notificationPanelOpen
        }
    }

    IpcHandler {
        target: "power"
        function toggle() {
            GlobalStates.powerMenuOpen = !GlobalStates.powerMenuOpen
        }
    }

    IpcHandler {
        target: "bar"
        function hide() {
            GlobalStates.barVisible = false
        }
        function show() {
            GlobalStates.barVisible = true
        }
        function reveal() {
            GlobalStates.barVisible = true
        }
        function unhide() {
            GlobalStates.barVisible = true
        }
        function toggle() {
            GlobalStates.barVisible = !GlobalStates.barVisible
        }
    }
}
