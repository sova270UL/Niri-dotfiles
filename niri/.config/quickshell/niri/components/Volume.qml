import QtQuick
import qs.theme
import qs.services
import Quickshell

Capsule {
    clickable: true
    onClicked: Quickshell.execDetached(["pavucontrol"])
    onScrolled: delta => Audio.changeBy(delta > 0 ? 0.05 : -0.05)

    Text {
        text: Audio.icon + " " + Audio.percent + "%"
        color: Audio.muted ? Qt.alpha(Colors.foreground, 0.5) : Colors.foreground
        font.family: "Noto Sans Mono"
        font.pixelSize: 14
    }
}
