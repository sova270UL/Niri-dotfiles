#!/usr/bin/env fish
set theme_file ~/dotfiles/niri/.config/quickshell/niri/theme/Theme.qml
if grep -q 'launcherGrid: false' $theme_file
    sed -i 's/launcherGrid: false/launcherGrid: true/' $theme_file
    echo "Режим лаунчера: сетка"
else
    sed -i 's/launcherGrid: true/launcherGrid: false/' $theme_file
    echo "Режим лаунчера: список"
end
pkill quickshell
qs -c niri &
