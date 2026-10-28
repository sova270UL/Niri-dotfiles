import QtQuick
import qs.theme
import qs.services

Capsule {
    clickable: true
    onClicked: Panels.toggle("wifi")

    BarText {
        text: Net.icon
        color: Net.online ? Colors.foreground : Colors.accent
    }
}
