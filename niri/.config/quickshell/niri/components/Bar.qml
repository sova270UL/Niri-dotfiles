import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import qs.theme
import qs.services

// Bar.qml - новый бар с интеграцией лаунчера

PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    
    // Размеры для лаунчера
    readonly property real cardWidth: Theme.panelWidth
    readonly property real cardHeight: Theme.launcherHeight
    property real progress: Launcher.open ? 1 : 0
    readonly property bool expanded: progress > 0
    readonly property string outline: buildOutline(width, progress)
    
    // Анимация появления/исчезновения лаунчера
    Behavior on progress {
        NumberAnimation { duration: Theme.launcherMs; easing.type: Easing.OutCubic }
    }
    
    // Функция построения контура (SVG-путь)
    function buildOutline(W, p) {
        const i = Theme.borderWidth / 2;
        const r = Theme.radius;
        const L = i, R = W - i, T = i, B = Theme.barHeight - i;
        let d = `M ${L + r} ${T} L ${R - r} ${T} A ${r} ${r} 0 0 1 ${R} ${T + r}`
            + ` L ${R} ${B - r} A ${r} ${r} 0 0 1 ${R - r} ${B}`;
        
        const cw = Theme.panelWidth * p;
        const ch = Theme.launcherHeight * p;
        const x0 = (W - cw) / 2 + i;
        const x1 = (W + cw) / 2 - i;
        const cb = Theme.barHeight + ch - i;
        if (x1 - x0 > 2 && ch > 2) {
            const f = Math.min(r, ch / 2);
            const rc = Math.min(r, (x1 - x0) / 2, ch / 2);
            d += ` L ${x1 + f} ${B} A ${f} ${f} 0 0 0 ${x1} ${B + f}`
                + ` L ${x1} ${cb - rc} A ${rc} ${rc} 0 0 1 ${x1 - rc} ${cb}`
                + ` L ${x0 + rc} ${cb} A ${rc} ${rc} 0 0 1 ${x0} ${cb - rc}`
                + ` L ${x0} ${B + f} A ${f} ${f} 0 0 0 ${x0 - f} ${B}`;
        }
        
        d += ` L ${L + r} ${B} A ${r} ${r} 0 0 1 ${L} ${B - r}`
            + ` L ${L} ${T + r} A ${r} ${r} 0 0 1 ${L + r} ${T} Z`;
        return d;
    }
    
    anchors { top: true; left: true; right: true }
    margins { top: Theme.barMargin; left: Theme.gap; right: Theme.gap }
    implicitHeight: Theme.barHeight + (expanded ? cardHeight : 0)
    exclusiveZone: Theme.barHeight
    color: "transparent"
    
    // Слой для лаунчера
    WlrLayershell.layer: expanded ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.keyboardFocus: Launcher.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    
    // Закрытие при клике вне
    MouseArea {
        anchors.fill: parent
        enabled: Launcher.open
        onClicked: Launcher.close()
    }
    
    // Контур бара + лаунчер
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
    
    // Содержимое бара (левый край, центр, правый край)
    Item {
        width: parent.width
        height: Theme.barHeight
        
        // левый край
        Row {
            spacing: Theme.spacing
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing
            anchors.verticalCenter: parent.verticalCenter
            Capsule {
                Workspaces { output: modelData.name }
            }
        }
        
        // центр (часы)
        Row {
            spacing: Theme.spacing
            anchors.centerIn: parent
            Clock {}
        }
        
        // правый край
        Row {
            spacing: Theme.spacing
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing
            anchors.verticalCenter: parent.verticalCenter
            Tray {}
            KeyboardLayout {}
            Volume {}
            NetworkStatus {}
        }
    }
    
    // Лоадер для лаунчера
    Loader {
        id: launcherLoader
        active: Launcher.open || root.expanded
        x: (parent.width - root.cardWidth) / 2 + Theme.panelPadding
        y: Theme.barHeight + Theme.panelPadding
        width: root.cardWidth - Theme.panelPadding * 2
        height: root.cardHeight - Theme.panelPadding * 2
        opacity: Math.max(0, (root.progress - 0.5) * 2)
        sourceComponent: LauncherContent {}
    }
}