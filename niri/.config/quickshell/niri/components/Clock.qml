import QtQuick
import Quickshell
import qs.theme

Capsule {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: Colors.foreground
        font.family: "Noto Sans Mono"
        font.pixelSize: 14
    }
}
