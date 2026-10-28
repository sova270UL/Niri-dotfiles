import Quickshell
import QtQuick
import qs.theme
import qs.services

Item {
    id: root
    focus: true

    property int currentIndex: 0

    readonly property var actions: [
        { icon: "", command: ["systemctl", "poweroff"] },
        { icon: "", command: ["systemctl", "reboot"] },
        { icon: "", command: ["niri", "msg", "action", "quit", "--skip-confirmation"] }
    ]

    function run(i) {
        const action = actions[i]
        Panels.close()
        Quickshell.execDetached(action.command)
    }

    Component.onCompleted: forceActiveFocus()

    Keys.onPressed: event => {
        const ctrl = event.modifiers & Qt.ControlModifier
        if (event.key === Qt.Key_Escape) {
            Panels.close()
        } else if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
            currentIndex = Math.min(currentIndex + 1, actions.length - 1)
        } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
            currentIndex = Math.max(currentIndex - 1, 0)
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            run(currentIndex)
        } else {
            return
        }
        event.accepted = true
    }

    Column {
        width: parent.width
        spacing: Theme.spacing

        Repeater {
            model: root.actions

            Rectangle {
                id: cell
                required property var modelData
                required property int index

                width: parent.width
                height: Theme.rowHeight
                radius: Theme.radius
                color: root.currentIndex === index ? Qt.alpha(Colors.accent, Theme.selectionOpacity) : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.animationMs } }

                BarText {
                    anchors.centerIn: parent
                    text: cell.modelData.icon
                    font.pixelSize: Theme.powerIconSize
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: root.currentIndex = cell.index
                    onClicked: root.run(cell.index)
                }
            }
        }
    }
}
