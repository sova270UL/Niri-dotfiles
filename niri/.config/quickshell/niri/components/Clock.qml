import QtQuick
import Quickshell

Capsule {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    BarText { text: Qt.formatDateTime(clock.date, "HH:mm") }
}
