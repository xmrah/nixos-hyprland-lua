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
        name: "overview"
        function toggle() {
            GlobalStates.overviewOpen = !GlobalStates.overviewOpen
        }
    }
}
