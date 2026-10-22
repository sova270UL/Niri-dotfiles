import QtQuick
import Quickshell
import qs.theme
import qs.services

Capsule {
    clickable: true
    onClicked: Quickshell.execDetached(["kitty", "--class", "nmtui", "nmtui"])

    BarText {
        text: Net.icon
        color: Net.online ? Colors.foreground : Colors.accent
    }
}
