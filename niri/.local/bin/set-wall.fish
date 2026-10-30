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

# Запоминаем выбор
mkdir -p (dirname $state_file)
echo $wall > $state_file