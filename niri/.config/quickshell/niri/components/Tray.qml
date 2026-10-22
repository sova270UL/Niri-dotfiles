import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.theme



Capsule {
    visible: repeater.count > 0

    Row {
        spacing: Theme.innerSpacing

        Repeater {
            id: repeater
            model: SystemTray.items

            Image {
                id: icon
                required property var modelData

                width: Theme.iconSize
                height: Theme.iconSize
                sourceSize: Qt.size(Theme.iconSize, Theme.iconSize)
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
