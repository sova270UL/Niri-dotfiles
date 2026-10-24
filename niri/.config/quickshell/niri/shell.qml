// shell.qml - обновленный файл без старого лаунчера

//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import qs.components
import qs.services

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }
    
    // IPC для лаунчера (уже в Launcher.qml)
    IpcHandler {
        target: "launcher"
        function toggle(): void { Launcher.toggle() }
    }
}