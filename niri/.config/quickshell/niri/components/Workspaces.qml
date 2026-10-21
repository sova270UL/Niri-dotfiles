import QtQuick
import qs.theme
import qs.services

Row {
    id: root
    required property string output
    spacing: 6

    Repeater {
        model: NiriState.workspacesFor(root.output)

        Rectangle {
            required property var modelData
            width: modelData.is_active ? 15 : 10
            height: 8
            radius: 5
            color: modelData.is_active ? Colors.accent : Qt.alpha(Colors.foreground, 0.4)
        }
    }
}
