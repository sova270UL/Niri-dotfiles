import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Capsule {
    visible: repeater.count > 0

    Row {
        spacing: 6

        Repeater {
            id: repeater
            model: SystemTray.items

            Image {
                id: icon
                required property var modelData

                width: 14
                height: 14
                sourceSize: Qt.size(14, 14)
                source: modelData.icon

                function openMenu() {
                    if (!modelData.hasMenu) return
                    const pos = icon.mapToItem(null, 0, 0)
                    modelData.display(QsWindow.window, pos.x, QsWindow.window.height)
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        if (mouse.button === Qt.MiddleButton) {
                            icon.modelData.secondaryActivate()
                        } else if (mouse.button === Qt.RightButton || icon.modelData.onlyMenu) {
                            icon.openMenu()
                        } else {
                            icon.modelData.activate()
                        }
                    }
                    onWheel: wheel => icon.modelData.scroll(wheel.angleDelta.y, false)
                }
            }
        }
    }
}
