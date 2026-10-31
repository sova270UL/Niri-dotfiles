import QtQuick
import Quickshell
import qs.theme
import qs.services

Capsule {
    clickable: true
    onClicked: Quickshell.execDetached(["pavucontrol"])
    onScrolled: delta => Audio.changeBy(delta > 0 ? 0.05 : -0.05)

    BarText {
        text: Audio.icon + " " + Audio.percent + "%"
        opacity: Audio.muted ? Theme.dimOpacity : 1
    }
}
