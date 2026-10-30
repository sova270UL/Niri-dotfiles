//@ pragma UseQApplication
//@ pragma IconTheme Adwaita
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

    Variants {
        model: Quickshell.screens
        VisualizerWindow {}
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

    IpcHandler {
        target: "media"
        function toggle(): void { if (Media.player) Panels.toggle("media") }
    }

    IpcHandler {
        target: "calendar"
        function toggle(): void { Panels.toggle("calendar") }
    }

    IpcHandler {
        target: "visualizer"
        function toggle(): void { Cava.enabled = !Cava.enabled }
        function preset(name: string): void { Cava.preset = name }
    }
}