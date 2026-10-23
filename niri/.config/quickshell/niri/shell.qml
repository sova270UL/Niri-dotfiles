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

    LazyLoader {
        active: Launcher.open
        AppLauncher {}
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { Launcher.toggle() }
    }
}
