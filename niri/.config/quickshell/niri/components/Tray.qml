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

                QsMenuAnchor {
                    id: menu
                    menu: icon.modelData.menu
                    anchor.item: icon
                    anchor.edges: Edges.Bottom | Edges.Left
                    anchor.gravity: Edges.Bottom | Edges.Right
                    anchor.rect.height: icon.height + 6
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        const item = icon.modelData
                        if (mouse.button === Qt.MiddleButton) {
                            item.secondaryActivate()
                        } else if ((mouse.button === Qt.RightButton || item.onlyMenu) && item.hasMenu) {
                            menu.open()
                        } else {
                            item.activate()
                        }
                    }
                    onWheel: wheel => icon.modelData.scroll(wheel.angleDelta.y, false)
                }
            }
        }
    }
}
