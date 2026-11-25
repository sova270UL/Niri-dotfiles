#!/usr/bin/env fish

# Снимок экрана и правка в satty: открывает интерфейс снимка niri и, как только
# снимок готов, открывает satty с ним. Снимок берётся из буфера обмена: niri
# кладёт его туда и при сохранении на диск, и при копировании без записи файла.
#
# Первый аргумент — действие niri (по умолчанию screenshot), чтобы скрипт можно
# было проверить неинтерактивным screenshot-screen.

set -l action screenshot
if test (count $argv) -gt 0
    set action $argv[1]
end

set -l lock $XDG_RUNTIME_DIR/niri-screenshot-satty.lock

# --- ожидание снимка: запускается повторно, под flock ---
if set -q SATTY_SHOT_WAIT
    # Поток событий пишем в fifo и читаем через grep: по совпадению grep выходит
    # сразу, а поток снимаем сами, иначе пришлось бы ждать таймаут целиком.
    # Обёртка sh нужна потому, что fish сам блокируется на открытии fifo на запись.
    set -l fifo $XDG_RUNTIME_DIR/niri-screenshot-satty.fifo
    unlink $fifo 2>/dev/null
    mkfifo $fifo
    timeout 120 sh -c "niri msg --json event-stream > $fifo" &
    set -l stream $last_pid
    grep -m1 -q ScreenshotCaptured <$fifo
    set -l captured $status
    kill $stream 2>/dev/null
    unlink $fifo
    exit $captured
end

# --- обычный запуск ---
niri msg action $action
or exit 1

# Ожидатель запускается отдельным процессом, поэтому код выхода берём у flock
# в фореграунде. Ждать снимок может только один процесс: иначе повторное нажатие
# откроет два satty на один снимок. Лок отпускается вместе с ожиданием, поэтому
# открытый satty не мешает следующему снимку.
set -x SATTY_SHOT_WAIT 1
flock -n $lock fish (status filename)
set -l captured $status
set -e SATTY_SHOT_WAIT

if test $captured -eq 0; and wl-paste --list-types 2>/dev/null | grep -q image/png
    wl-paste --type image/png | satty --filename -
end
