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

    SysInfoPopup {}
    Overview {}

    IpcHandler {
        target: "overview"
        function toggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen
        }
    }
}
