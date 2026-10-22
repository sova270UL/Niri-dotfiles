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

    Rectangle {
        anchors.fill: parent
        radius: 9
        color: Qt.alpha(Colors.background, 0.5)
        border.width: 2
        border.color: Colors.accent

        // левый край
        Row {
            spacing: 5
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.verticalCenter: parent.verticalCenter

            Capsule {
                Workspaces { output: modelData.name }
            }
        }

        // Центр
        Row {
            spacing: 5
            anchors.centerIn: parent

            Clock {}
        }

        // правый край
        Row {
            spacing: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter

            Tray{}

            KeyboardLayout {}

            Volume {}

            NetworkStatus {}
        }
    }
}
