import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell 0.1

pragma Singleton

Item {
    id: launcherRoot
    width: 400
    height: 400
    
    property bool isOpen: false
    property bool shortcutActive: false
    
    onShortcutActiveChanged: {
        if (shortcutActive && !isOpen) {
            isOpen = true;
            launcherBg.scale = 0.8;
            launcherBg.opacity = 0;
            PropertyAnimation {
                target: launcherBg
                property: "scale"
                from: 0.8
                to: 1.0
                duration: 150
                easing: Easing.OutCubic
            }
            PropertyAnimation {
                target: launcherBg
                property: "opacity"
                from: 0
                to: 1
                duration: 150
            }
        } else if (!shortcutActive && isOpen) {
            isOpen = false;
            PropertyAnimation {
                target: launcherBg
                property: "scale"
                from: 1.0
                to: 0.8
                duration: 150
                easing: Easing.InCubic
            }
            PropertyAnimation {
                target: launcherBg
                property: "opacity"
                from: 1
                to: 0
                duration: 150
                onFinished: {
                    launcherRoot.visible = false;
                }
            }
        }
    }
    
    Rectangle {
        id: launcherBg
        anchors.fill: parent
        color: "#2e2e2e"
        opacity: 0.9
        radius: 9
        visible: isOpen
    }
    
    // Тестовая сетка иконок
    Grid {
        anchors.fill: parent
        anchors.margins: 20
        columns: 8
        rows: 8
        spacing: 10
        itemHeight: (height - 7 * spacing) / 8
        itemWidth: (width - 7 * spacing) / 8
        
        Repeater {
            model: 64
            delegate: Rectangle {
                width: itemWidth
                height: itemHeight
                color: "#3e3e3e"
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Clicked item");
                    }
                }
            }
        }
    }
}