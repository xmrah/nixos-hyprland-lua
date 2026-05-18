// Sovereign Shell — Entry Point
// Hyprland 0.55 Native Lua API ile tam entegrasyon
import Quickshell

ShellRoot {
    // Her ekran için ayrı bar
    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }
}
