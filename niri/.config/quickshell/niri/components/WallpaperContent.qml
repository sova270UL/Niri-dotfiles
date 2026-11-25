import Quickshell
import Quickshell.Widgets
import QtQuick
import qs.theme
import qs.services

Item {
    id: root
    focus: true

    property bool settingsOpen: false
    property int currentIndex: 0
    property string draftDirectory: ""
    property string dirError: ""

    readonly property var images: Wallpapers.images
    readonly property string selectedPath: images.length > 0
        ? images[Math.max(0, Math.min(currentIndex, images.length - 1))] : ""

    function fileUrl(path) {
        return "file://" + path.split("/").map(encodeURIComponent).join("/")
    }

    function setIndex(index) {
        if (images.length === 0) return
        root.currentIndex = Math.max(0, Math.min(index, images.length - 1))
        view.currentIndex = root.currentIndex
        view.positionViewAtIndex(root.currentIndex, ListView.Contain)
    }

    function syncCurrent() {
        const index = images.indexOf(Wallpapers.current)
        root.setIndex(index >= 0 ? index : 0)
        view.positionViewAtIndex(root.currentIndex, ListView.Beginning)
    }

    function openSettings() {
        root.settingsOpen = true
        root.dirError = ""
        root.draftDirectory = Wallpapers.directory
        input.text = root.draftDirectory
        Qt.callLater(function() {
            input.forceActiveFocus()
            input.selectAll()
        })
    }

    function closeSettings() {
        root.settingsOpen = false
        root.dirError = ""
        root.forceActiveFocus()
    }

    function commitSettings() {
        Wallpapers.requestDirectory(input.text)
    }

    function applyCurrent() {
        if (Wallpapers.apply(root.selectedPath)) Panels.close()
    }

    Component.onCompleted: {
        Wallpapers.scan()
        root.syncCurrent()
        root.forceActiveFocus()
    }

    Connections {
        target: Wallpapers
        function onImagesChanged() { root.syncCurrent() }
        function onCurrentChanged() { root.syncCurrent() }
        function onDirectoryAccepted() { root.closeSettings() }
        function onDirectoryRejected() {
            root.dirError = "Каталог не найден"
            Qt.callLater(function() {
                input.forceActiveFocus()
                input.selectAll()
            })
        }
    }

    Keys.onPressed: event => {
        if (root.settingsOpen) {
            if (event.key === Qt.Key_Escape) {
                root.closeSettings()
                event.accepted = true
            }
            return
        }
        if (event.key === Qt.Key_Escape) {
            Panels.close()
        } else if (event.key === Qt.Key_Left) {
            root.setIndex(root.currentIndex - 1)
        } else if (event.key === Qt.Key_Right) {
            root.setIndex(root.currentIndex + 1)
        } else if (event.key === Qt.Key_Home) {
            root.setIndex(0)
        } else if (event.key === Qt.Key_End) {
            root.setIndex(root.images.length - 1)
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            root.applyCurrent()
        } else {
            return
        }
        event.accepted = true
    }

    Column {
        width: parent.width
        spacing: Theme.spacing

        Row {
            width: parent.width
            height: Theme.rowHeight
            spacing: Theme.spacing

            Capsule {
                id: backButton
                width: Theme.wallpaperButtonSize
                height: Theme.rowHeight
                clickable: true
                onClicked: Panels.toggle("launcher")

                BarText { text: "󰁍" }
            }

            Rectangle {
                id: pathBox
                width: parent.width - backButton.width - gearButton.width - parent.spacing * 2
                height: parent.height
                radius: Theme.radius
                color: Qt.alpha(Colors.foreground, Theme.capsuleOpacity)
                clip: true

                BarText {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.capsulePadding
                    anchors.rightMargin: Theme.capsulePadding
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideMiddle
                    text: Wallpapers.displayDirectory
                    visible: !root.settingsOpen
                    opacity: Theme.softOpacity
                }

                BarText {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.capsulePadding
                    anchors.rightMargin: Theme.capsulePadding
                    verticalAlignment: Text.AlignVCenter
                    text: "Путь к каталогу"
                    opacity: Theme.dimOpacity
                    visible: root.settingsOpen && input.text === ""
                }

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: Theme.capsulePadding
                    anchors.rightMargin: Theme.capsulePadding
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.dirError !== "" ? Colors.accent : Colors.foreground
                    selectionColor: Colors.accent
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    clip: true
                    visible: root.settingsOpen
                    onTextChanged: root.dirError = ""
                    onAccepted: root.commitSettings()
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.closeSettings()
                            event.accepted = true
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: !root.settingsOpen
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openSettings()
                }
            }

            Capsule {
                id: gearButton
                width: Theme.wallpaperButtonSize
                height: Theme.rowHeight
                clickable: true
                onClicked: root.settingsOpen ? root.commitSettings() : root.openSettings()

                BarText { text: root.settingsOpen ? "󰄬" : "󰒓" }
            }
        }

        Item {
            id: previewBox
            width: parent.width
            height: Theme.wallpaperPreviewHeight

            ClippingRectangle {
                anchors.fill: parent
                radius: Theme.radius
                color: Qt.alpha(Colors.foreground, Theme.capsuleOpacity)

                Image {
                    anchors.fill: parent
                    sourceSize.width: Theme.panelWidth - Theme.panelPadding * 2
                    sourceSize.height: Theme.wallpaperPreviewHeight
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                    source: root.selectedPath !== "" ? root.fileUrl(root.selectedPath) : ""
                }
            }

            BarText {
                anchors.centerIn: parent
                text: Wallpapers.loading ? "Сканирую…" : "Ничего не найдено"
                opacity: Theme.dimOpacity
                visible: !root.settingsOpen && (Wallpapers.loading || root.images.length === 0)
            }

            BarText {
                anchors.centerIn: parent
                color: Colors.accent
                text: root.dirError
                visible: root.settingsOpen && root.dirError !== ""
            }
        }

        ListView {
            id: view
            width: parent.width
            height: Theme.wallpaperRowHeight
            orientation: ListView.Horizontal
            spacing: Theme.spacing
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            highlightFollowsCurrentItem: false
            reuseItems: true
            cacheBuffer: Theme.wallpaperCacheBuffer
            model: root.images

            onCurrentIndexChanged: root.currentIndex = currentIndex

            delegate: Item {
                id: cell
                required property var modelData
                required property int index

                width: Theme.wallpaperThumbWidth
                height: Theme.wallpaperThumbHeight

                ClippingRectangle {
                    anchors.fill: parent
                    radius: Theme.radius
                    color: Qt.alpha(Colors.foreground, Theme.capsuleOpacity)

                    Image {
                        anchors.fill: parent
                        sourceSize.width: Theme.wallpaperThumbWidth
                        sourceSize.height: Theme.wallpaperThumbHeight
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: false
                        source: root.fileUrl(cell.modelData)
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radius
                    color: "transparent"
                    z: 1
                    border.width: (cell.modelData === Wallpapers.current || cell.ListView.isCurrentItem)
                        ? Theme.borderWidth : 0
                    border.color: cell.modelData === Wallpapers.current
                        ? Colors.accent : Qt.alpha(Colors.accent, Theme.softOpacity)
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPositionChanged: {
                        view.currentIndex = cell.index
                        view.positionViewAtIndex(cell.index, ListView.Contain)
                    }
                    onClicked: {
                        view.currentIndex = cell.index
                        if (Wallpapers.apply(cell.modelData)) Panels.close()
                    }
                    onWheel: wheel => {
                        const delta = wheel.angleDelta.y !== 0 ? wheel.angleDelta.y : wheel.angleDelta.x
                        view.flick(-delta, 0)
                    }
                }
            }
        }
    }
}
