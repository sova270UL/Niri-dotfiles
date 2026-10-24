import Quickshell
import QtQuick
import qs.theme
import qs.services

Item {
    id: root

    readonly property var results: Launcher.search(input.text)

    Connections {
        target: Launcher
        onOpenChanged: {
            if (open) {
                if (Theme.launcherGrid && grid.count > 0) grid.currentIndex = 0
                else if (!Theme.launcherGrid && list.count > 0) list.currentIndex = 0
            }
        }
    }

    function launchCurrent() {
        if (Theme.launcherGrid) {
            if (grid.currentIndex >= 0)
                Launcher.launch(results[grid.currentIndex])
        } else {
            if (list.currentIndex >= 0)
                Launcher.launch(results[list.currentIndex])
        }
    }

    Component.onCompleted: input.forceActiveFocus()

    Column {
        id: launcherColumn
        width: parent.width
        spacing: Theme.spacing

        Rectangle {
            width: parent.width
            height: Theme.rowHeight
            radius: Theme.radius
            color: Qt.alpha(Colors.foreground, Theme.capsuleOpacity)

            BarText {
                anchors.fill: parent
                anchors.leftMargin: Theme.capsulePadding
                verticalAlignment: Text.AlignVCenter
                text: "Поиск приложения"
                opacity: 0.5
                visible: input.text === ""
            }

            TextInput {
                id: input
                anchors.fill: parent
                anchors.leftMargin: Theme.capsulePadding
                anchors.rightMargin: Theme.capsulePadding
                verticalAlignment: TextInput.AlignVCenter
                color: Colors.foreground
                selectionColor: Colors.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                clip: true
                focus: true

                onTextChanged: {
                    if (Theme.launcherGrid && grid.count > 0)
                        grid.currentIndex = 0
                    else if (!Theme.launcherGrid && list.count > 0)
                        list.currentIndex = 0
                }

                Keys.onPressed: event => {
                    const ctrl = event.modifiers & Qt.ControlModifier
                    const isGrid = Theme.launcherGrid

                    if (event.key === Qt.Key_Escape) {
                        Launcher.close()
                        event.accepted = true
                    } else if (isGrid && grid.count > 0) {
                        if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
                            grid.currentIndex = (grid.currentIndex + grid.effectiveCols) % grid.count
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
                            grid.currentIndex = (grid.currentIndex - grid.effectiveCols + grid.count) % grid.count
                            event.accepted = true
                        } else if (event.key === Qt.Key_Left || (ctrl && event.key === Qt.Key_H)) {
                            grid.currentIndex = (grid.currentIndex - 1 + grid.count) % grid.count
                            event.accepted = true
                        } else if (event.key === Qt.Key_Right || (ctrl && event.key === Qt.Key_L)) {
                            grid.currentIndex = (grid.currentIndex + 1) % grid.count
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launchCurrent()
                            event.accepted = true
                        }
                    } else {
                        if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
                            list.incrementCurrentIndex()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
                            list.decrementCurrentIndex()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launchCurrent()
                            event.accepted = true
                        }
                    }
                }
            }
        }

        // Список приложений
        ListView {
            id: list
            width: parent.width
            height: Theme.rowHeight * Theme.maxRows
            model: root.results
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: true
            visible: !Theme.launcherGrid

            delegate: Rectangle {
                id: row
                required property var modelData
                required property int index

                width: ListView.view.width
                height: Theme.rowHeight
                radius: Theme.radius
                color: ListView.isCurrentItem ? Qt.alpha(Colors.accent, Theme.selectionOpacity) : "transparent"

                Behavior on color { ColorAnimation { duration: Theme.animationMs } }

                Image {
                    id: icon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.capsulePadding
                    anchors.verticalCenter: parent.verticalCenter
                    width: Theme.rowIconSize
                    height: Theme.rowIconSize
                    sourceSize.width: Theme.rowIconSize
                    sourceSize.height: Theme.rowIconSize
                    asynchronous: true
                    source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                }

                BarText {
                    anchors.left: icon.right
                    anchors.leftMargin: Theme.innerSpacing + Theme.spacing
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.capsulePadding
                    anchors.verticalCenter: parent.verticalCenter
                    text: row.modelData.name
                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: list.currentIndex = index
                    onExited: if (list.currentIndex === index) list.currentIndex = -1
                    onClicked: Launcher.launch(row.modelData)
                }
            }
        }

        // Сетка иконок (центрирована, не вылезает за границы окна)
        GridView {
            id: grid
            // Сколько полных колонок помещается в доступную ширину
            property int effectiveCols: Math.min(Theme.launcherGridCols, Math.floor(launcherColumn.width / Theme.launcherCellSize))

            Component.onCompleted: if (Launcher.open && count > 0) currentIndex = 0
            width: effectiveCols * Theme.launcherCellSize
            height: root.results.length === 0
                ? 0
                : Theme.launcherCellSize * Math.ceil(root.results.length / effectiveCols)
                + Theme.spacing * (Math.ceil(root.results.length / effectiveCols) - 1)
            cellWidth: Theme.launcherCellSize
            cellHeight: Theme.launcherCellSize
            model: root.results
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            anchors.horizontalCenter: launcherColumn.horizontalCenter
            visible: Theme.launcherGrid

            delegate: Item {
                width: Theme.launcherCellSize
                height: Theme.launcherCellSize

                Rectangle {
                    id: cell
                    anchors.centerIn: parent
                    width: Theme.launcherCellSize - Theme.spacing * 2
                    height: Theme.launcherCellSize - Theme.spacing * 2
                    radius: Theme.radius
                    color: grid.currentIndex === index ? Qt.alpha(Colors.accent, Theme.selectionOpacity) : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.animationMs } }

                    Image {
                        id: icon
                        anchors.top: parent.top
                        anchors.topMargin: Theme.innerSpacing
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Theme.rowIconSize
                        height: Theme.rowIconSize
                        sourceSize.width: Theme.rowIconSize
                        sourceSize.height: Theme.rowIconSize
                        asynchronous: true
                        source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                    }

                    BarText {
                        anchors.top: icon.bottom
                        anchors.topMargin: Theme.innerSpacing
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Theme.launcherCellSize - Theme.spacing * 2
                        text: modelData.name
                        elide: Text.ElideRight
                        wrapMode: Text.NoWrap
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: grid.currentIndex = index
                        onExited: if (grid.currentIndex === index) grid.currentIndex = -1
                        onClicked: Launcher.launch(modelData)
                    }
                }
            }
        }
    }
}
