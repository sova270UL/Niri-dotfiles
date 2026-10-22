import QtQuick
import qs.theme

Rectangle {
    id: root
    default property alias content: row.data
    property int padding: Theme.capsulePadding
    property bool clickable: false

    readonly property bool hovered: mouse.containsMouse
    signal clicked()
    signal scrolled(int delta)

    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Theme.capsuleHeight
    radius: height / 2
    color: Qt.alpha(Colors.foreground,
        clickable && hovered ? Theme.capsuleHoverOpacity : Theme.capsuleOpacity)

    Behavior on color { ColorAnimation { duration: Theme.animationMs } }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
        onWheel: wheel => root.scrolled(wheel.angleDelta.y)
    }

    Row {
        id: row
        anchors.centerIn: parent
    }
}
