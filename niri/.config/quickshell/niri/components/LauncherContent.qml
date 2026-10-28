import Quickshell
import QtQuick
import qs.theme
import qs.services

Item {
    id: root

    readonly property var results: Launcher.search(input.text)

    function launchCurrent() {
        const entry = results[grid.currentIndex]
        if (entry) Launcher.launch(entry)
    }

    function step(move) {
        move()
        grid.positionViewAtIndex(grid.currentIndex, GridView.Contain)
    }

    Component.onCompleted: input.forceActiveFocus()

    Column {
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
                    grid.currentIndex = 0
                    grid.positionViewAtBeginning()
                }

                Keys.onPressed: event => {
                    const ctrl = event.modifiers & Qt.ControlModifier
                    if (event.key === Qt.Key_Escape) {
                        Launcher.close()
                    } else if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
                        root.step(() => grid.moveCurrentIndexDown())
                    } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
                        root.step(() => grid.moveCurrentIndexUp())
                    } else if (event.key === Qt.Key_Right) {
                        root.step(() => grid.moveCurrentIndexRight())
                    } else if (event.key === Qt.Key_Left) {
                        root.step(() => grid.moveCurrentIndexLeft())
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.launchCurrent()
                    } else {
                        return
                    }
                    event.accepted = true
                }
            }
        }

        GridView {
            id: grid
            width: Theme.gridCellWidth * Theme.gridColumns
            height: Theme.gridCellHeight * Theme.gridRows
            cellWidth: Theme.gridCellWidth
            cellHeight: Theme.gridCellHeight
            model: root.results
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            highlightFollowsCurrentItem: false
            reuseItems: true

            delegate: Item {
                id: cell
                required property var modelData
                required property int index

                width: GridView.view.cellWidth
                height: GridView.view.cellHeight

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: Theme.borderWidth
                    radius: Theme.radius
                    color: cell.GridView.isCurrentItem ? Qt.alpha(Colors.accent, Theme.selectionOpacity) : "transparent"

                    Behavior on color { ColorAnimation { duration: Theme.animationMs } }
                }

                Image {
                    id: icon
                    x: (parent.width - width) / 2
                    y: Theme.gridCellPadding
                    width: Theme.gridIconSize
                    height: Theme.gridIconSize
                    sourceSize.width: Theme.gridIconSize
                    sourceSize.height: Theme.gridIconSize
                    asynchronous: true
                    source: Quickshell.iconPath(cell.modelData.icon, "application-x-executable")
                }

                BarText {
                    x: Theme.spacing
                    y: icon.y + icon.height + Theme.spacing
                    width: parent.width - Theme.spacing * 2
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    font.pixelSize: Theme.gridFontSize
                    text: cell.modelData.name
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: grid.currentIndex = cell.index
                    onClicked: Launcher.launch(cell.modelData)
                }
            }

            BarText {
                anchors.centerIn: parent
                text: "Ничего не найдено"
                opacity: 0.5
                visible: grid.count === 0
            }
        }
    }
}
