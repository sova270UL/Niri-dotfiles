import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.theme
import qs.services

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    readonly property bool shown: Osd.active
        && Panels.current === ""
        && NiriState.focusedFullscreen
        && (NiriState.focusedOutput === "" || modelData.name === NiriState.focusedOutput)

    visible: shown || card.opacity > 0
    anchors { bottom: true }
    margins { bottom: Theme.osdBottomMargin }
    implicitWidth: Theme.osdWidth
    implicitHeight: Theme.osdHeight
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}

    WlrLayershell.namespace: "qs-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.radius
        color: Qt.alpha(Colors.background, Theme.launcherOpacity)
        border.width: Theme.borderWidth
        border.color: Colors.accent
        opacity: root.shown ? 1 : 0
        transform: Translate { y: (1 - card.opacity) * Theme.gap }

        Behavior on opacity {
            NumberAnimation { duration: Theme.animationMs; easing.type: Easing.OutCubic }
        }

        VolumeOsdContent {
            anchors.fill: parent
            anchors.margins: Theme.spacing
        }
    }
}
