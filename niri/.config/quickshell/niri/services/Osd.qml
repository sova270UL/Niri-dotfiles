pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

Singleton {
    id: root

    property bool active: false
    property bool armed: false

    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR")
    readonly property string soundFile: "$HOME/.local/share/sounds/niri/volume.ogg"
    readonly property string fallbackSound: "/usr/share/sounds/freedesktop/stereo/audio-volume-change.oga"

    function show(withSound) {
        if (!armed) return
        active = true
        hideTimer.restart()
        if (withSound && !player.running) player.running = true
    }

    Component.onCompleted: {
        volumeFile.setText("init")
        muteFile.setText("init")
    }

    Timer {
        interval: Theme.osdArmMs
        running: true
        onTriggered: root.armed = true
    }

    Timer {
        id: hideTimer
        interval: Theme.osdHideMs
        onTriggered: root.active = false
    }

    FileView {
        id: volumeFile
        path: root.runtimeDir + "/qs-osd-volume"
        watchChanges: true
        atomicWrites: false
        printErrors: false
        onFileChanged: {
            reload()
            root.show(true)
        }
    }

    FileView {
        id: muteFile
        path: root.runtimeDir + "/qs-osd-mute"
        watchChanges: true
        atomicWrites: false
        printErrors: false
        onFileChanged: {
            reload()
            root.show(false)
        }
    }

    Process {
        id: player
        command: ["fish", "-c", "pw-play " + root.soundFile + " 2>/dev/null; or pw-play " + root.fallbackSound + " 2>/dev/null"]
    }
}
