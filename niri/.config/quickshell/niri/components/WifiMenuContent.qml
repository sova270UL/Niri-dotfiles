import Quickshell
import Quickshell.Networking
import QtQuick
import qs.theme
import qs.services

Item {
    id: root
    focus: true

    property var entries: []
    property string currentKey: ""
    property string signature: ""
    property bool rebuilding: false

    function level(n) {
        return Math.min(3, Math.floor(n.signalStrength * 4))
    }

    function rebuild() {
        const result = [{ key: "toggle", kind: "toggle" }]
        const device = Net.wifiDevice
        if (device && Networking.wifiEnabled) {
            const best = {}
            for (const n of device.networks.values) {
                if (!n.name) continue
                if (!n.connected && n.signalStrength < Theme.wifiMinStrength) continue
                const old = best[n.name]
                if (!old || n.connected || (!old.connected && n.signalStrength > old.signalStrength))
                    best[n.name] = n
            }
            Object.values(best)
                .sort((a, b) => (b.connected - a.connected)
                    || (level(b) - level(a))
                    || a.name.localeCompare(b.name))
                .forEach(n => result.push({ key: "net:" + n.name, kind: "network", network: n }))
        }
        result.push({ key: "other", kind: "other" })

        const sig = result.map(e => e.key + (e.network && e.network.connected ? "*" : "")).join("|")
        if (sig === signature) return
        signature = sig

        rebuilding = true
        entries = result
        const idx = result.findIndex(e => e.key === currentKey)
        view.currentIndex = idx >= 0 ? idx : 0
        view.positionViewAtIndex(view.currentIndex, ListView.Contain)
        rebuilding = false
    }

    function openNmtui() {
        Panels.close()
        Quickshell.execDetached(["kitty", "--class", "nmtui", "nmtui"])
    }

    function activate(entry) {
        if (!entry) return
        if (entry.kind === "toggle") {
            Networking.wifiEnabled = !Networking.wifiEnabled
        } else if (entry.kind === "other") {
            openNmtui()
        } else if (entry.network.connected) {
            entry.network.disconnect()
        } else if (entry.network.known) {
            entry.network.connect()
        } else {
            openNmtui()
        }
    }

    function step(move) {
        move()
        view.positionViewAtIndex(view.currentIndex, ListView.Contain)
    }

    Component.onCompleted: {
        if (Net.wifiDevice) Net.wifiDevice.scannerEnabled = true
        rebuild()
        forceActiveFocus()
    }

    Component.onDestruction: {
        if (Net.wifiDevice) Net.wifiDevice.scannerEnabled = false
    }

    Timer {
        interval: Theme.wifiRefreshMs
        running: true
        repeat: true
        onTriggered: root.rebuild()
    }

    Timer {
        interval: Theme.wifiScanMs
        running: true
        onTriggered: {
            if (Net.wifiDevice) Net.wifiDevice.scannerEnabled = false
        }
    }

    Connections {
        target: Net.wifiDevice ? Net.wifiDevice.networks : null
        function onValuesChanged() { root.rebuild() }
    }

    Keys.onPressed: event => {
        const ctrl = event.modifiers & Qt.ControlModifier
        if (event.key === Qt.Key_Escape) {
            Panels.close()
        } else if (event.key === Qt.Key_Down || (ctrl && (event.key === Qt.Key_N || event.key === Qt.Key_J))) {
            step(() => view.incrementCurrentIndex())
        } else if (event.key === Qt.Key_Up || (ctrl && (event.key === Qt.Key_P || event.key === Qt.Key_K))) {
            step(() => view.decrementCurrentIndex())
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            activate(entries[view.currentIndex])
        } else {
            return
        }
        event.accepted = true
    }

    ListView {
        id: view
        anchors.fill: parent
        model: root.entries
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        highlightFollowsCurrentItem: false

        onCurrentIndexChanged: {
            if (!root.rebuilding && root.entries[currentIndex])
                root.currentKey = root.entries[currentIndex].key
        }

        delegate: Rectangle {
            id: row
            required property var modelData
            required property int index

            readonly property bool isToggle: modelData.kind === "toggle"
            readonly property bool isNetwork: modelData.kind === "network"
            readonly property var network: isNetwork ? modelData.network : null

            width: ListView.view.width
            height: Theme.rowHeight
            radius: Theme.radius
            color: ListView.isCurrentItem ? Qt.alpha(Colors.accent, Theme.selectionOpacity) : "transparent"
            opacity: network && network.stateChanging ? 0.5 : 1

            Behavior on color { ColorAnimation { duration: Theme.animationMs } }

            BarText {
                id: lead
                anchors.left: parent.left
                anchors.leftMargin: Theme.capsulePadding
                anchors.verticalCenter: parent.verticalCenter
                text: row.isToggle
                    ? (Networking.wifiEnabled ? Net.wifiIcon(1) : "󰤮")
                    : row.isNetwork ? Net.wifiIcon(row.network.signalStrength) : ""
            }

            BarText {
                id: trail
                anchors.right: parent.right
                anchors.rightMargin: Theme.capsulePadding
                anchors.verticalCenter: parent.verticalCenter
                color: Colors.accent
                text: row.isToggle
                    ? (Networking.wifiEnabled ? "вкл" : "выкл")
                    : (row.isNetwork && row.network.connected) ? "󰄬" : ""
                visible: text !== ""
            }

            BarText {
                anchors.left: lead.right
                anchors.leftMargin: Theme.innerSpacing + Theme.spacing
                anchors.right: trail.visible ? trail.left : parent.right
                anchors.rightMargin: Theme.spacing
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                color: (row.isNetwork && row.network.connected) ? Colors.accent : Colors.foreground
                text: row.isToggle ? "Wi-Fi" : row.isNetwork ? row.network.name : "Другие сети"
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPositionChanged: view.currentIndex = row.index
                onClicked: root.activate(row.modelData)
            }
        }
    }
}
