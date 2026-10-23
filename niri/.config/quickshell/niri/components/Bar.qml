import Quickshell
import QtQuick
import qs.theme

// Bar.qml - обновленный бар с интеграцией лаунчера

PanelWindow {
    required property var modelData
    screen: modelData
    
    anchors { top: true; left: true; right: true }
    margins { top: Theme.barMargin; left: Theme.gap; right: Theme.gap }
    implicitHeight: Theme.barHeight
    color: "transparent"
    
    Rectangle {
        anchors.fill: parent
        radius: Theme.radius
        color: Qt.alpha(Colors.background, Theme.barOpacity)
        border.width: Theme.borderWidth
        border.color: Colors.accent
        
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
        
        // центр - с часами и ссылкой для лаунчера
        Item {
            id: centerBar
            anchors.centerIn: parent
            width: parent.width - Theme.spacing * 4
            height: parent.height
            
            // Часы
            Clock {
                id: clockItem
                anchors.centerIn: parent
            }
            
            // Точка для позиционирования лаунчера
            Rectangle {
                id: launcherAnchor
                anchors.centerIn: clockItem
                width: 0
                height: 0
                visible: false
            }
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
    
    // Интеграция лаунчера
    property Item launcherBridge: LauncherBridge {
        bar: parent
        clockItem: centerBar.clockItem
        onShowLauncher: {
            // Открываем лаунчер через сигнал
            var launcher = LauncherBridge.findLauncher(parent);
            if (launcher) launcher.openLauncher();
        }
    }
}