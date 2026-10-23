// LauncherDesktopParser.qml - парсинг desktop-файлов (исправленный путь)

pragma Singleton

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.LocalStorage 2.1

Item {
    id: parser
    property var appsModel: null
    
    Component.onCompleted: {
        parseApplications();
    }
    
    function parseApplications() {
        var model = [];
        var desktopDirs = ["/usr/share/applications", "/usr/local/share/applications"];
        
        for (var d = 0; d < desktopDirs.length; d++) {
            var dir = desktopDirs[d];
            var files = [];
            
            // Читаем файлы через QML FileModel (нужно реализовать через C++)
            // Для теста используем заглушку
            files = getSampleApps();
            
            for (var f = 0; f < files.length; f++) {
                var desktop = files[f];
                var entry = parseDesktopEntry(desktop.path, desktop.content);
                if (entry && entry.Name) {
                    // Добавляем иконку по умолчанию, если нет
                    if (!entry.Icon) entry.Icon = "applications-all";
                    model.push(entry);
                }
            }
        }
        
        // Сортировка по алфавиту
        model.sort(function(a, b) {
            var nameA = a.Name || '';
            var nameB = b.Name || '';
            return nameA.localeCompare(nameB);
        });
        
        parser.appsModel = model;
    }
    
    function parseDesktopEntry(path, content) {
        var lines = content.split('\n');
        var entry = {};
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim();
            if (line === '' || line.startsWith('#')) continue;
            if (line.startsWith('[Desktop Entry]')) continue;
            if (line.startsWith('[') && line.endsWith(']')) continue;
            var parts = line.split('=');
            if (parts.length < 2) continue;
            var key = parts[0].trim();
            var value = parts.slice(1).join('=').trim();
            
            switch(key) {
                case 'Name':
                    entry.Name = value.split(';')[0];
                    break;
                case 'Icon':
                    entry.Icon = value;
                    break;
                case 'Exec':
                    entry.Exec = value;
                    break;
                case 'Type':
                    entry.Type = value;
                    break;
            }
        }
        return entry;
    }
    
    function getSampleApps() {
        // Заглушка для теста — в реальности нужно читать файлы
        return [
            {path: "firefox.desktop", content: "[Desktop Entry]\nType=Application\nName=Firefox\nIcon=firefox\nExec=firefox"},
            {path: "kitty.desktop", content: "[Desktop Entry]\nType=Application\nName=Kitty\nIcon=terminal\nExec=kitty"},
            {path: "thunar.desktop", content: "[Desktop Entry]\nType=Application\nName=Thunar\nIcon=system-file-manager\nExec=thunar"},
            {path: "code.desktop", content: "[Desktop Entry]\nType=Application\nName=VS Code\nIcon=code\nExec=code"},
            {path: "telegram.desktop", content: "[Desktop Entry]\nType=Application\nName=Telegram\nIcon=telegram\nExec=telegram"}
        ];
    }
}