pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property color background: adapter.background
    property color foreground: adapter.foreground
    property color accent: adapter.accent

    FileView {
        path: Quickshell.shellPath("theme/colors.json")
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter
            property color background: "#1e1e2e"
            property color foreground: "#cdd6f4"
            property color accent: "#7fc8ff"
        }
    }
}
