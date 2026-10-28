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

    Variants {
        model: Quickshell.screens
        VolumeOsd {}
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { Launcher.toggle() }
    }

    IpcHandler {
        target: "power"
        function toggle(): void { Panels.toggle("power") }
    }

    IpcHandler {
        target: "wifi"
        function toggle(): void { Panels.toggle("wifi") }
    }

    IpcHandler {
        target: "volume"
        function show(): void { Osd.show(true) }
    }
}