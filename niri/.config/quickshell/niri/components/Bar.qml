import Quickshell
import QtQuick
import qs.theme

PanelWindow {
    required property var modelData
    screen: modelData

    anchors { top: true; left: true; right: true }
    margins { top: Theme.barMargin; left: Theme.gap; right: Theme.gap }
    implicitHeight: Theme.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Qt.alpha(Colors.background, Theme.barOpacity)
        border.width: Theme.borderWidth
        border.color: Colors.accent

        // левый край
        Row {
            spacing: Theme.spacing
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing
            anchors.verticalCenter: parent.verticalCenter

            Capsule {
                Workspaces { output: modelData.name }
            }
        }

        // центр
        Row {
            spacing: Theme.spacing
            anchors.centerIn: parent

            Clock {}
        }

        // правый край
        Row {
            spacing: Theme.spacing
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing
            anchors.verticalCenter: parent.verticalCenter

            Tray {}
            KeyboardLayout {}
            Volume {}
            NetworkStatus {}
        }
    }
}
