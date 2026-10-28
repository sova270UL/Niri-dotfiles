import QtQuick
import qs.theme
import qs.services

Capsule {
    clickable: true
    onClicked: Panels.toggle("power")

    BarText {
        text: "\uF011"
    }
}