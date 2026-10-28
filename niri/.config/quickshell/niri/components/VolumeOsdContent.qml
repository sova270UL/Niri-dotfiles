import QtQuick
import qs.theme
import qs.services

Item {
    Row {
        anchors.fill: parent
        spacing: Theme.innerSpacing + Theme.spacing

        BarText {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            text: Audio.icon
            font.pixelSize: Theme.osdIconSize
        }

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - icon.width - percent.width - parent.spacing * 2
            height: Theme.osdTrackHeight
            radius: height / 2
            color: Qt.alpha(Colors.foreground, Theme.capsuleHoverOpacity)

            Rectangle {
                width: parent.width * Math.min(1, Audio.volume)
                height: parent.height
                radius: height / 2
                color: Colors.accent
                opacity: Audio.muted ? 0.4 : 1

                Behavior on width {
                    NumberAnimation { duration: Theme.animationMs; easing.type: Easing.OutCubic }
                }
            }
        }

        BarText {
            id: percent
            anchors.verticalCenter: parent.verticalCenter
            width: Theme.osdPercentWidth
            horizontalAlignment: Text.AlignRight
            text: Audio.percent + "%"
            opacity: Audio.muted ? 0.5 : 1
        }
    }
}
