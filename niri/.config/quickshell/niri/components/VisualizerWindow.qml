import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.theme
import qs.services

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    readonly property bool shown: Cava.wanted && NiriState.emptyWorkspace(modelData.name)
    readonly property var presets: ({ bottom: bottomPreset })

    visible: shown || content.opacity > 0
    anchors { left: true; right: true; bottom: true }
    implicitHeight: Theme.visualizerHeight
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    mask: Region {}

    WlrLayershell.namespace: "qs-visualizer"
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Component {
        id: bottomPreset
        VisualizerBottom { values: Cava.values }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: root.shown ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.visualizerFadeMs; easing.type: Easing.OutCubic }
        }

        Loader {
            anchors.fill: parent
            active: root.visible
            sourceComponent: root.presets[Cava.preset] || bottomPreset
        }
    }
}
