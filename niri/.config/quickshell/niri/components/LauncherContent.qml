import Quickshell
import QtQuick
import qs.theme
import qs.services

Item {
    id: root

    readonly property var tabs: Launcher.tabs
    property int tabIndex: 0
    readonly property string tabId: tabs.length > 0 ? tabs[Math.min(tabIndex, tabs.length - 1)].id : "all"
    readonly property var results: Launcher.search(tabId, input.text)

    function launchCurrent() {
        const entry = results[grid.currentIndex]
        if (entry) Launcher.launch(entry)
    }

    function step(move) {
        move()
        grid.positionViewAtIndex(grid.currentIndex, GridView.Contain)
    }

    function selectTab(index) {
        const count = tabs.length
        if (count === 0) return
        tabIndex = ((index % count) + count) % count
        grid.currentIndex = 0
        grid.positionViewAtBeginning()
        revealTab(tabIndex)
        input.forceActiveFocus()
    }

    function revealTab(index) {
        const item = tabRepeater.itemAt(index)
        if (!item) return
        const maxX = Math.max(0, tabBar.contentWidth - tabBar.width)
        const target = Math.max(0, Math.min(item.x - (tabBar.width - item.width) / 2, maxX))
        tabScroll.to = target
        tabScroll.restart()
    }

    Component.onCompleted: {
        input.forceActiveFocus()
        Qt.callLater(revealTab, tabIndex)
    }

    onTabsChanged: Qt.callLater(revealTab, tabIndex)

    NumberAnimation {
        id: tabScroll
        target: tabBar
        property: "contentX"
        duration: Theme.animationMs
        easing.type: Easing.OutCubic
    }

    Column {
        width: parent.width
        spacing: Theme.spacing

        Row {
            width: parent.width
            height: Theme.rowHeight
            spacing: Theme.spacing

            Rectangle {
                id: searchBox
                width: parent.width - wallpaperButton.width - parent.spacing
                height: parent.height
                radius: Theme.radius
                color: Qt.alpha(Colors.foreground, Theme.capsuleOpacity)

                BarText {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.capsulePadding
                    verticalAlignment: Text.AlignVCenter
                    text: "Поиск приложения"
                    opacity: Theme.dimOpacity
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
                        } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Backtab) {
                            const back = event.key === Qt.Key_Backtab || (event.modifiers & Qt.ShiftModifier)
                            root.selectTab(root.tabIndex + (back ? -1 : 1))
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launchCurrent()
                        } else {
                            return
                        }
                        event.accepted = true
                    }
                }
            }

            Capsule {
                id: wallpaperButton
                width: Theme.wallpaperButtonSize
                height: Theme.rowHeight
                clickable: true
                onClicked: Panels.toggle("wallpaper")

                BarText { text: "󰈟" }
            }
        }

        Flickable {
            id: tabBar
            width: parent.width
            height: Theme.launcherTabsHeight
            contentWidth: tabRow.implicitWidth
            contentHeight: height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Row {
                id: tabRow
                spacing: Theme.spacing

                Repeater {
                    id: tabRepeater
                    model: root.tabs

                    Capsule {
                        id: tabItem
                        required property var modelData
                        required property int index

                        readonly property bool current: index === root.tabIndex

                        clickable: true
                        color: current
                            ? Qt.alpha(Colors.accent, Theme.selectionOpacity)
                            : Qt.alpha(Colors.foreground, hovered ? Theme.capsuleHoverOpacity : Theme.capsuleOpacity)
                        onClicked: root.selectTab(index)
                        onScrolled: delta => tabBar.flick(-delta * 12, 0)

                        BarText { text: tabItem.modelData.title }
                    }
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
                    source: Launcher.iconFor(cell.modelData)
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
                opacity: Theme.dimOpacity
                visible: grid.count === 0
            }
        }

        // Клик по пустому месту внутри виджета — закрыть панель.
        // Интерактивные элементы имеют свои MouseArea и не доходят сюда.
        MouseArea {
            anchors.fill: parent
            onClicked: Panels.close()
        }
    }
}
