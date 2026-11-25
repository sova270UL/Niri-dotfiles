import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.theme
import qs.services

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
                asynchronous: true
                source: modelData.icon

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: mouse => {
                        const item = icon.modelData
                        if (mouse.button === Qt.MiddleButton) {
                            item.secondaryActivate()
                        } else if ((mouse.button === Qt.RightButton || item.onlyMenu) && item.hasMenu) {
                            TrayMenu.show(item, icon, menuWindow)
                        } else {
                            item.activate()
                        }
                    }
                    onWheel: wheel => icon.modelData.scroll(wheel.angleDelta.y, false)
                }
            }
        }
    }

    PopupWindow {
        id: menuWindow
        visible: TrayMenu.popup === menuWindow
        grabFocus: true
        implicitWidth: card.width
        implicitHeight: card.height
        color: "transparent"

        anchor.window: TrayMenu.anchorItem ? TrayMenu.anchorItem.QsWindow.window : null
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right

        onVisibleChanged: {
            if (visible) menuContent.forceActiveFocus()
            else if (TrayMenu.popup === menuWindow) TrayMenu.close()
        }

        Connections {
            target: menuWindow.anchor
            function onAnchoring() {
                const anchorItem = TrayMenu.anchorItem
                if (!anchorItem) return
                const r = anchorItem.QsWindow.itemRect(anchorItem)
                menuWindow.anchor.rect.x = r.x
                menuWindow.anchor.rect.y = r.y
                menuWindow.anchor.rect.width = r.width
                menuWindow.anchor.rect.height = r.height + Theme.innerSpacing
            }
        }

        Rectangle {
            id: card
            width: Math.max(Theme.spacing * 2 + menuContent.implicitWidth,
                Theme.rowHeight + Theme.spacing * 2)
            height: Math.max(Theme.spacing * 2 + menuContent.implicitHeight,
                Theme.rowHeight + Theme.spacing * 2)
            radius: Theme.radius
            color: Qt.alpha(Colors.background, Theme.launcherOpacity)
            border.color: Colors.accent
            border.width: Theme.borderWidth

            TrayMenuContent {
                id: menuContent
                x: Theme.spacing
                y: Theme.spacing
            }
        }
    }
}
