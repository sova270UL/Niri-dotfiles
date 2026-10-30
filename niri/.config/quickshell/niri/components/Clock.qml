import QtQuick
import Quickshell
import qs.services

Capsule {
    clickable: true
    onClicked: Panels.toggle("calendar")

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    BarText { text: Qt.formatDateTime(clock.date, "HH:mm") }
}
