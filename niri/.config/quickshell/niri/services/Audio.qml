pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property real volume: ready ? sink.audio.volume : 0
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property int percent: Math.round(volume * 100)

    readonly property string icon: {
        if (!ready || muted || volume === 0) return "\uDB81\uDF5F"
        if (volume < 0.34) return "\uDB81\uDD7F"
        if (volume < 0.67) return "\uDB81\uDD80"
        return "\uDB81\uDD7E"
    }

    function changeBy(delta) {
        if (ready) sink.audio.volume = Math.max(0, Math.min(1, volume + delta))
    }

    function toggleMute() {
        if (ready) sink.audio.muted = !sink.audio.muted
    }

    PwObjectTracker { objects: [root.sink] }
}
