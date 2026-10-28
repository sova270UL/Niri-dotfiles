import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import qs.theme
import qs.services

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    property string shownKind: "launcher"

    readonly property bool onFocusedOutput: NiriState.focusedOutput === ""
        || modelData.name === NiriState.focusedOutput
    readonly property bool panelHere: Panels.current !== "" && onFocusedOutput
    readonly property bool osdHere: Panels.current === ""
        && Osd.active
        && !NiriState.focusedFullscreen
        && onFocusedOutput
    readonly property bool interactive: panelHere || (expanded && shownKind !== "volume")

    readonly property bool flushRight: shownKind !== "launcher"
    readonly property real cardWidth: shownKind === "power" ? powerButton.width + Theme.spacing
        : shownKind === "wifi" ? Theme.wifiPanelWidth
        : shownKind === "volume" ? Theme.osdWidth : Theme.panelWidth
    readonly property real cardHeight: shownKind === "power" ? Theme.powerMenuHeight
        : shownKind === "wifi" ? Theme.wifiPanelHeight
        : shownKind === "volume" ? Theme.osdHeight : Theme.launcherHeight
    readonly property real cardX: flushRight ? width - cardWidth : (width - cardWidth) / 2
    readonly property real contentPadding: flushRight ? Theme.spacing : Theme.panelPadding

    property real progress: (panelHere || osdHere) ? 1 : 0
    readonly property bool expanded: progress > 0
    readonly property string outline: buildOutline(width, progress, cardX, cardWidth, cardHeight, !flushRight)

    Behavior on progress {
        NumberAnimation { duration: Theme.launcherMs; easing.type: Easing.OutCubic }
    }

    Connections {
        target: Panels
        function onCurrentChanged() {
            if (Panels.current !== "") root.shownKind = Panels.current
        }
    }

    onOsdHereChanged: if (osdHere) shownKind = "volume"

    function buildOutline(W, p, cx, cw, chFull, growWidth) {
        const i = Theme.borderWidth / 2
        const r = Theme.radius
        const L = i, R = W - i, T = i, B = Theme.barHeight - i
        const flush = cx + cw >= W - 0.5
        const ch = chFull * p
        const cwNow = growWidth ? cw * p : cw
        const x0 = cx + (cw - cwNow) / 2 + i
        const x1 = flush ? R : cx + (cw + cwNow) / 2 - i
        const cb = Theme.barHeight + ch - i
        const showCard = x1 - x0 > 2 && ch > 2

        let d = `M ${L + r} ${T} L ${R - r} ${T} A ${r} ${r} 0 0 1 ${R} ${T + r}`

        if (showCard && flush) {
            const f = Math.min(r, ch / 2)
            const rc = Math.min(r, (x1 - x0) / 2, ch / 2)
            d += ` L ${R} ${cb - rc} A ${rc} ${rc} 0 0 1 ${R - rc} ${cb}`
                + ` L ${x0 + rc} ${cb} A ${rc} ${rc} 0 0 1 ${x0} ${cb - rc}`
                + ` L ${x0} ${B + f} A ${f} ${f} 0 0 0 ${x0 - f} ${B}`
        } else {
            d += ` L ${R} ${B - r} A ${r} ${r} 0 0 1 ${R - r} ${B}`
            if (showCard) {
                const f = Math.min(r, ch / 2)
                const rc = Math.min(r, (x1 - x0) / 2, ch / 2)
                d += ` L ${x1 + f} ${B} A ${f} ${f} 0 0 0 ${x1} ${B + f}`
                    + ` L ${x1} ${cb - rc} A ${rc} ${rc} 0 0 1 ${x1 - rc} ${cb}`
                    + ` L ${x0 + rc} ${cb} A ${rc} ${rc} 0 0 1 ${x0} ${cb - rc}`
                    + ` L ${x0} ${B + f} A ${f} ${f} 0 0 0 ${x0 - f} ${B}`
            }
        }

        d += ` L ${L + r} ${B} A ${r} ${r} 0 0 1 ${L} ${B - r}`
            + ` L ${L} ${T + r} A ${r} ${r} 0 0 1 ${L + r} ${T} Z`
        return d
    }

    anchors { top: true; left: true; right: true }
    margins { top: Theme.barMargin; left: Theme.gap; right: Theme.gap }
    implicitHeight: Theme.barHeight + (expanded ? cardHeight : 0)
    exclusiveZone: Theme.barHeight
    color: "transparent"

    mask: Region {
        x: 0
        y: 0
        width: root.width
        height: root.interactive ? root.height : Theme.barHeight
    }

    WlrLayershell.layer: expanded && interactive ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.keyboardFocus: panelHere ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        enabled: root.panelHere
        onClicked: Panels.close()
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: Qt.alpha(Colors.background, Theme.barOpacity + (Theme.launcherOpacity - Theme.barOpacity) * root.progress)
            strokeColor: Colors.accent
            strokeWidth: Theme.borderWidth
            PathSvg { path: root.outline }
        }
    }

    Item {
        width: parent.width
        height: Theme.barHeight

        Row {
            spacing: Theme.spacing
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing
            anchors.verticalCenter: parent.verticalCenter

            Capsule {
                Workspaces { output: modelData.name }
            }
            KeyboardLayout {}
        }

        Row {
            spacing: Theme.spacing
            anchors.centerIn: parent

            Clock {}
        }

        Row {
            spacing: Theme.spacing
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing
            anchors.verticalCenter: parent.verticalCenter

            Tray {}
            Volume {}
            NetworkStatus {}
            PowerButton { id: powerButton }
        }
    }

    Component { id: launcherComponent; LauncherContent {} }
    Component { id: powerComponent; PowerMenuContent {} }
    Component { id: wifiComponent; WifiMenuContent {} }
    Component { id: volumeComponent; VolumeOsdContent {} }

    Loader {
        active: root.panelHere || root.osdHere || root.expanded
        x: root.cardX + root.contentPadding
        y: Theme.barHeight + root.contentPadding
        width: root.cardWidth - root.contentPadding * 2
        height: root.cardHeight - root.contentPadding * 2
        opacity: Math.max(0, (root.progress - 0.5) * 2)
        sourceComponent: root.shownKind === "power" ? powerComponent
            : root.shownKind === "wifi" ? wifiComponent
            : root.shownKind === "volume" ? volumeComponent : launcherComponent
    }
}
