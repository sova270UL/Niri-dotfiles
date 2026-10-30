import QtQuick
import qs.theme
import qs.services

Capsule {
    visible: Media.player !== null
    clickable: true
    onClicked: Panels.toggle("media")

    BarText {
        width: Math.min(implicitWidth, Theme.mediaBarMaxWidth)
        elide: Text.ElideRight
        text: (Media.player && Media.player.isPlaying ? "\uF001" : "\uF04C") + " "
            + (Media.player ? (Media.player.trackTitle || Media.player.identity) : "")
    }
}
