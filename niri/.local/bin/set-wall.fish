#!/usr/bin/env fish

# Параметры перехода awww
set -l transition_type grow
set -l transition_fps 60
set -l transition_duration 1.5

# Файл, где запоминается текущий выбор обоев (для восстановления после входа)
set -l state_file ~/.local/state/niri-wall/current


# Проверка аргумента: нужен ровно один путь к картинке
if test (count $argv) -ne 1
    echo "Использование: set-wall.fish /путь/к/обоям.png" >&2
    exit 1
end

set -l wall (realpath $argv[1])
if not test -f $wall
    echo "set-wall: файл не найден: $wall" >&2
    exit 1
end

# Проверка, что демон обоев запущен
if not awww query >/dev/null 2>&1
    echo "set-wall: awww-daemon не запущен" >&2
    exit 1
end

# Смена обоев с анимацией
if not awww img $wall --transition-type $transition_type --transition-fps $transition_fps --transition-duration $transition_duration
    echo "set-wall: awww не смог поставить обои" >&2
    exit 1
end

# Пересборка палитры: wallust пишет файлы для Quickshell, mako и niri
if not wallust run $wall
    echo "set-wall: wallust завершился с ошибкой" >&2
    exit 1
end

# mako читает конфиг только при перезагрузке
makoctl reload

# Светлая/тёмная тему системы по яркости фона обоев, чтобы приложения
# подхватили соответствующую тему (GTK цветовая схема и оформление).
if command -v gsettings >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1
    set -l scheme (python3 -c '
import json, os
c = json.load(open(os.path.expanduser("~/.config/quickshell/niri/theme/colors.json")))
h = c["background"].lstrip("#")
r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
lum = (0.299 * r + 0.587 * g + 0.114 * b) / 255
print("prefer-dark" if lum < 0.5 else "prefer-light")
' 2>/dev/null)
    if test -n "$scheme"
        gsettings set org.gnome.desktop.interface color-scheme "$scheme" >/dev/null 2>&1 || true
        if test "$scheme" = "prefer-dark"
            gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" >/dev/null 2>&1 || true
        else
            gsettings set org.gnome.desktop.interface gtk-theme "Adwaita" >/dev/null 2>&1 || true
        end
    end
end

# Запоминаем выбор
mkdir -p (dirname $state_file)
echo $wall > $state_file