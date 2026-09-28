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
            // TODO: Quickshell native launcher implemente edilecek
            GlobalStates.launcherOpen = !GlobalStates.launcherOpen
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle() {
            // TODO: Quickshell native clipboard UI implemente edilecek
            GlobalStates.clipboardOpen = !GlobalStates.clipboardOpen
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
    }
}
