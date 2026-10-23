#!/bin/bash
# niri-launcher.sh - автономный лаунчер приложений
# Работает без зависимости от quickshell

# Настройки
BAR_HEIGHT=25
LAUNCHER_WIDTH=400
LAUNCHER_HEIGHT=400

# Позиционирование под часы (центр бара)
# Получаем координаты через xdotool или грубую оценку
CLOCK_X=$(xdotool getwindowgeometry $(xdotool search --classname "niri" | head -n 1) | grep "Width" | awk '{print $2}')
CLOCK_Y=$(xdotool getwindowgeometry $(xdotool search --classname "niri" | head -n 1) | grep "X" | awk '{print $2}')

if [ -z "$CLOCK_X" ]; then
    # Грубая оценка если не нашли окно niri
    CLOCK_X=1920
    CLOCK_Y=25
fi

LAUNCHER_X=$((CLOCK_X - LAUNCHER_WIDTH / 2))
LAUNCHER_Y=$((CLOCK_Y + 30))

# Создаем окно лаунчера через yad (если установлен) или xterm
if command -v yad >/dev/null 2>&1; then
    yad --window="pos=$LAUNCHER_X,$LAUNCHER_Y" --width=$LAUNCHER_WIDTH --height=$LAUNCHER_HEIGHT \
        --title="Niri Launcher" --center --undecorated --sticky \
        --gtk-theme="Yad" --button="Close"=1 --button="Cancel"=2 &
    LAUNCHER_PID=$!
    sleep 0.5
    # Закрываем окно при клике вне
    while kill -0 $LAUNCHER_PID 2>/dev/null; do
        if ! xdotool getactivewindow | grep -q "yad"; then
            kill $LAUNCHER_PID
            break
        fi
        sleep 0.1
    done
else
    # Фоллбэк на xterm
    xterm -geometry 80x24 -T "Niri Launcher" -e "echo 'Launcher test - press Enter to close'; read; exit" &
    LAUNCHER_PID=$!
    sleep 0.5
    kill $LAUNCHER_PID
fi
