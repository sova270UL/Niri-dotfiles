import QtQuick
import qs.theme
import qs.services

Item {
    id: root
    focus: true

    readonly property var player: Media.player
    readonly property real length: player && player.lengthSupported ? player.length : 0
    readonly property real position: player && player.positionSupported ? player.position : 0

    readonly property var buttons: ["prev", "toggle", "next"]

    function format(seconds) {
        const t = Math.max(0, Math.floor(seconds))
        return Math.floor(t / 60) + ":" + String(t % 60).padStart(2, "0")
    }

    function icon(kind) {
        if (kind === "prev") return "\uF048"
        if (kind === "next") return "\uF051"
        return player && player.isPlaying ? "\uF04C" : "\uF04B"
    }

    function available(kind) {
        if (!player) return false
        if (kind === "prev") return player.canGoPrevious
        if (kind === "next") return player.canGoNext
        return player.canTogglePlaying
    }

    function run(kind) {
        if (!available(kind)) return
        if (kind === "prev") player.previous()
        else if (kind === "next") player.next()
        else player.togglePlaying()
    }

    function seekTo(x, width) {
        if (player && player.canSeek && player.positionSupported && length > 0)
            player.position = Math.max(0, Math.min(1, x / width)) * length
    }

    Component.onCompleted: forceActiveFocus()

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            Panels.close()
        } else if (event.key === Qt.Key_Space) {
            run("toggle")
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_N) {
            run("next")
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_P) {
            run("prev")
        } else {
            return
        }
        event.accepted = true
    }

    Timer {
        interval: Theme.mediaTickMs
        repeat: true
        running: root.player !== null && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    Column {
        anchors.fill: parent
        spacing: Theme.spacing

        Row {
            width: parent.width
            height: Theme.mediaCoverSize
            spacing: Theme.spacing * 2

            Rectangle {
                id: cover
                width: Theme.mediaCoverSize
                height: Theme.mediaCoverSize
                color: Qt.alpha(Colors.foreground, Theme.capsuleOpacity)

                BarText {
                    anchors.centerIn: parent
                    text: "\uF001"
                    font.pixelSize: Theme.powerIconSize * 2
                    opacity: 0.5
                    visible: art.status !== Image.Ready
                }

                Image {
                    id: art
                    anchors.fill: parent
                    source: root.player ? root.player.trackArtUrl : ""
                    asynchronous: true
                    fillMode: Image.PreserveAspectCrop
                    sourceSize.width: Theme.mediaCoverSize * 2
                    sourceSize.height: Theme.mediaCoverSize * 2
                }
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - cover.width - parent.spacing
                spacing: Theme.spacing

                BarText {
                    width: parent.width
                    elide: Text.ElideRight
                    font.bold: true
                    text: root.player ? (root.player.trackTitle || root.player.identity) : ""
                }

                BarText {
                    width: parent.width
                    elide: Text.ElideRight
                    opacity: 0.7
                    text: root.player ? root.player.trackArtist : ""
                }

                BarText {
                    width: parent.width
                    elide: Text.ElideRight
                    opacity: 0.5
                    font.pixelSize: Theme.mediaTimeFontSize
                    text: root.player ? root.player.identity : ""
                }
            }
        }

        Row {
            width: parent.width
            height: Theme.mediaProgressHeight
            spacing: Theme.spacing

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.mediaTimeWidth
                opacity: 0.7
                font.pixelSize: Theme.mediaTimeFontSize
                text: root.format(root.position)
            }

            Item {
                width: parent.width - Theme.mediaTimeWidth * 2 - parent.spacing * 2
                height: parent.height

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: Theme.mediaTrackHeight
                    radius: height / 2
                    color: Qt.alpha(Colors.foreground, Theme.capsuleHoverOpacity)

                    Rectangle {
                        width: root.length > 0 ? parent.width * Math.min(1, root.position / root.length) : 0
                        height: parent.height
                        radius: height / 2
                        color: Colors.accent
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => root.seekTo(mouse.x, width)
                }
            }

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                width: Theme.mediaTimeWidth
                horizontalAlignment: Text.AlignRight
                opacity: 0.7
                font.pixelSize: Theme.mediaTimeFontSize
                text: root.format(root.length)
            }
        }

        Item {
            width: parent.width
            height: Theme.rowHeight

            Row {
                anchors.centerIn: parent
                spacing: Theme.spacing

                Repeater {
                    model: root.buttons

                    Rectangle {
                        id: button
                        required property string modelData

                        width: Theme.mediaButtonWidth
                        height: Theme.rowHeight
                        radius: Theme.radius
                        color: Qt.alpha(Colors.accent, mouse.containsMouse && root.available(modelData) ? Theme.selectionOpacity : 0)
                        opacity: root.available(modelData) ? 1 : 0.3

                        Behavior on color { ColorAnimation { duration: Theme.animationMs } }

                        BarText {
                            anchors.centerIn: parent
                            text: root.icon(button.modelData)
                            font.pixelSize: Theme.powerIconSize
                        }

                        MouseArea {
                            id: mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.run(button.modelData)
                        }
                    }
                }
            }
        }
    }
}
