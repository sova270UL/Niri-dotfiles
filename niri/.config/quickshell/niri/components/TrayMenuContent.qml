import QtQuick
import Quickshell
import qs.theme
import qs.services

Item {
    id: root
    focus: true

    implicitWidth: list.width
    implicitHeight: Math.min(list.height, Theme.trayMenuMaxHeight)

    function press(row, entry) {
        if (entry.hasChildren) {
            const p = row.mapToItem(root, 0, 0)
            TrayMenu.submenu(entry, p.x + root.x, p.y + row.height + root.y)
            return
        }
        TrayMenu.activate(entry)
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            TrayMenu.close()
            event.accepted = true
        }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: list.height
        clip: true
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: list
            width: childrenRect.width
            spacing: Theme.spacing

            Repeater {
                model: TrayMenu.rows

                Rectangle {
                    id: row
                    required property var modelData
                    required property int index

                    readonly property var entry: modelData.entry
                    readonly property bool hasIcon: entry.icon && entry.icon.length > 0

                    width: Theme.capsulePadding * 2
                        + (hasIcon ? Theme.iconSize + Theme.innerSpacing + Theme.spacing : 0)
                        + label.implicitWidth
                        + (trail.visible ? Theme.innerSpacing + trail.implicitWidth : 0)
                    height: Theme.rowHeight
                    radius: Theme.radius
                    color: hover.containsMouse && entry.enabled
                        ? Qt.alpha(Colors.accent, Theme.selectionOpacity) : "transparent"
                    opacity: entry.enabled ? 1 : Theme.dimOpacity

                    Behavior on color { ColorAnimation { duration: Theme.animationMs } }

                    Rectangle {
                        x: Theme.capsulePadding
                        y: -(Theme.spacing + Theme.borderWidth) / 2
                        width: parent.width - Theme.capsulePadding * 2
                        height: Theme.borderWidth
                        color: Qt.alpha(Colors.accent, Theme.faintOpacity)
                        visible: row.modelData.separator
                    }

                    Image {
                        visible: row.hasIcon
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.capsulePadding
                        anchors.verticalCenter: parent.verticalCenter
                        width: Theme.iconSize
                        height: Theme.iconSize
                        sourceSize: Qt.size(Theme.iconSize, Theme.iconSize)
                        asynchronous: true
                        source: row.entry.icon
                    }

                    BarText {
                        id: label
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.capsulePadding
                            + (row.hasIcon ? Theme.iconSize + Theme.innerSpacing + Theme.spacing : 0)
                        anchors.verticalCenter: parent.verticalCenter
                        text: row.entry.text
                    }

                    BarText {
                        id: trail
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.capsulePadding
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.accent
                        text: row.entry.buttonType !== QsMenuButtonType.None
                            ? (row.entry.checkState === Qt.Checked ? "[x]" : "[ ]")
                            : row.entry.hasChildren ? ">" : ""
                        visible: text !== ""
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: row.entry.enabled
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.press(row, row.entry)
                    }
                }
            }
        }
    }
}
