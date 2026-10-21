import Quickshell
import QtQuick
import qs.theme

PanelWindow {
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    margins { top: 4; left: 7; right: 7 }
    implicitHeight: 25
    color: "transparent"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Rectangle {
        anchors.fill: parent
        radius: 9
        color: Qt.alpha(Colors.background, 0.85)
        border.width: 2
        border.color: Colors.accent


        Workspaces {
            output: modelData.name
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: Colors.foreground
            font.family: "Noto Sans Mono"
            font.pixelSize: 14
        }
    }
}
