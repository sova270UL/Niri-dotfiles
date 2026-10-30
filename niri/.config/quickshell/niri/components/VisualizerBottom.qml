import QtQuick
import qs.theme

Item {
    id: root

    property var values: []
    readonly property int count: values.length
    readonly property real barWidth: count > 0
        ? (width - Theme.visualizerGap * (count - 1)) / count : 0

    Repeater {
        model: root.count

        Rectangle {
            required property int index
            readonly property real level: Math.min(1, root.values[index] || 0)

            x: index * (root.barWidth + Theme.visualizerGap)
            width: root.barWidth
            height: Math.max(Theme.visualizerMinBar, level * root.height)
            y: root.height - height
            radius: Math.min(width / 2, Theme.radius)
            color: Colors.accent
            opacity: Theme.visualizerMinOpacity + (1 - Theme.visualizerMinOpacity) * level

            Behavior on height {
                NumberAnimation { duration: Theme.visualizerSmoothMs }
            }
        }
    }
}
