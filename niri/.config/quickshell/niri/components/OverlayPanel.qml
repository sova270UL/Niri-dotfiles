import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.theme

PanelWindow {
    id: root
    default property alias content: slot.data
    signal dismissed()

    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    WlrLayershell.namespace: "qs-panel"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
    }

    Rectangle {
        id: card
        property bool shown: false

        width: Theme.panelWidth
        height: slot.height + Theme.panelPadding * 2
        x: (parent.width - width) / 2
        y: parent.height * Theme.panelTopRatio

        radius: Theme.radius
        color: Qt.alpha(Colors.background, Theme.panelOpacity)
        border.width: Theme.borderWidth
        border.color: Colors.accent

        opacity: shown ? 1 : 0
        scale: 0.97 + 0.03 * opacity
        Behavior on opacity { NumberAnimation { duration: Theme.animationMs } }
        Component.onCompleted: shown = true

        MouseArea { anchors.fill: parent }

        Item {
            id: slot
            x: Theme.panelPadding
            y: Theme.panelPadding
            width: parent.width - Theme.panelPadding * 2
            height: childrenRect.height
        }
    }
}
