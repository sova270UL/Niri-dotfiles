import QtQuick
import qs.theme
import qs.services

Row {
    id: root
    required property string output
    spacing: Theme.workspaceSpacing

    Repeater {
        model: NiriState.workspacesFor(root.output)

        Rectangle {
            required property var modelData
            width: modelData.is_active ? Theme.workspaceActiveWidth : Theme.workspaceDotWidth
            height: Theme.workspaceDotHeight
            radius: height / 2
            color: modelData.is_active ? Colors.accent : Qt.alpha(Colors.foreground, Theme.workspaceInactiveOpacity)
        }
    }
}
