import QtQuick 2.15
import QtQuick.Controls 2.15
import Quickshell 0.1
import Quickshell.Services 0.1

pragma Singleton

// LauncherBridge.qml - соединение лаунчера с баром
// Обеспечивает позиционирование относительно часов

Item {
    id: launcherBridge
    property Item bar: null
    property Item clockItem: null
    
    // Сигнал, когда лаунчер должен появиться
    signal showLauncher()
    
    // Обработчик бинда из keybinds
    function handleLauncherBind() {
        // Временное решение — показываем лаунчер через сигнал
        launcherBridge.showLauncher();
    }
    
    // Позиционирование лаунчера относительно часов
    onShowLauncher: {
        // Находим лаунчер в родителе
        var launcher = launcherBridge.findLauncher();
        if (launcher && launcherBridge.clockItem) {
            // Позиционируем под часами
            launcher.x = launcherBridge.clockItem.x + launcherBridge.clockItem.width / 2 - launcher.width / 2;
            launcher.y = launcherBridge.clockItem.y + launcherBridge.clockItem.height + theme.spacing;
            launcher.openLauncher();
        }
    }
    
    function findLauncher() {
        // Поиск лаунчера в иерархии
        var parent = launcherBridge.parent;
        while (parent) {
            if (parent.hasOwnProperty('isLauncher') && parent.isLauncher) {
                return parent;
            }
            parent = parent.parent;
        }
        return null;
    }
}