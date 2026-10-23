import Quickshell
import QtQuick
import qs.theme
import qs.services

OverlayPanel {
    id: root
    onDismissed: Launcher.close()

    readonly property var results: Launcher.search(input.text)

    function launchCurrent() {
        const entry = results[list.currentIndex]
        if (entry) Launcher.launch(entry)
    }

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

                onTextChanged: list.currentIndex = 0
                Component.onCompleted: forceActiveFocus()

                Keys.onPressed: event => {
                    const ctrl = event.modifiers & Qt.ControlModifier
                    if (event.key === Qt.Key_Escape) {
                        Launcher.close()
                    } else if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
                        list.incrementCurrentIndex()
                    } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
                        list.decrementCurrentIndex()
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.launchCurrent()
                    } else {
                        return
                    }
                    event.accepted = true
                }
            }
        }

        ListView {
            id: list
            width: parent.width
            height: Theme.rowHeight * Theme.maxRows
            model: root.results
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: true

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
                    onPositionChanged: list.currentIndex = row.index
                    onClicked: Launcher.launch(row.modelData)
                }
            }

            BarText {
                anchors.centerIn: parent
                text: "Ничего не найдено"
                opacity: 0.5
                visible: list.count === 0
            }
        }
    }
}
