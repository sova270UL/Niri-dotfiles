//@ pragma IconTheme Adwaita
import Quickshell
import Quickshell.Io
import QtQuick
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
        function reindex(): void { Launcher.writeIndex() }
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
        target: "wallpaper"
        function toggle(): void { Panels.toggle("wallpaper") }
    }

    IpcHandler {
        target: "visualizer"
        function toggle(): void { Cava.enabled = !Cava.enabled }
        function preset(name: string): void { Cava.preset = name }
    }
}