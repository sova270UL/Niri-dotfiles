pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

Singleton {
    id: root

    property bool enabled: true
    property string preset: Theme.visualizerPreset
    property var values: []

    readonly property bool playing: !Theme.visualizerRequirePlayback
        || (Media.player !== null && Media.player.isPlaying)
    readonly property bool wanted: enabled && playing && NiriState.anyEmptyWorkspace

    Process {
        command: ["cava", "-p", Quickshell.shellPath("cava.conf")]
        running: root.wanted
        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(";").filter(s => s !== "")
                root.values = parts.map(s => Number(s) / Theme.visualizerMaxRange)
            }
        }
    }
}
