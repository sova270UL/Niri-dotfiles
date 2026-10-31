# Задание агенту: исправления по полному ревью проекта

Режим Build. Ты исполнитель, решения приняты. Содержимое новых файлов вставляй ровно как написано.

## Цель

Исправить замечания полного ревью: удалить мёртвый код и заглушки, исправить опечатки в комментариях, убрать хардкод и вынести литеральные `opacity` в токены `Theme`. Пункт 4.9 роадмапа (анимация лаунчера) не трогать — пользователь вернётся к нему позже.

## Жёсткие правила

1. Git не трогать: никаких `add`, `commit`, `push`, `stash`, `reset`, `checkout`, `restore`.
2. Менять только файлы из шагов ниже. `Osd.qml`, `Audio.qml`, `Net.qml`, `Media.qml`, `NiriState.qml`, `Cava.qml`, `Bar.qml`, `VisualizerWindow.qml`, `VisualizerBottom.qml`, `Clock.qml`, `shell.qml`, `cava.conf` не трогать.
3. Визуальные значения не менять: новые токены содержат те же числа, что и удаляемые литералы (0.5, 0.7, 0.3, 0.4).
4. Команды в синтаксисе fish, без heredoc. `rm` заблокирован окружением — файлы удалять через `unlink`.
5. Если шаг невыполним как написано, остановиться и объяснить причину, не импровизировать.
6. Комментарии в коде не добавлять.

## Что найдено ревью (контекст шагов)

- `niri/.local/bin/launcher-toggle-mode.fish` — осиротевший скрипт: переключает несуществующий токен `launcherGrid` (в `Theme.qml` его нет), команда `pkill quickshell` не находит процесс (живой процесс называется `qs`, проверено: `pkill -x quickshell` возвращает 1), ни на что не ссылается — ни бинда, ни упоминания в роадмапе.
- `windowrule.kdl` — пустое правило freshgram (только `match` без действий) и wezterm-правило от дефолтного конфига (wezterm не установлен). Это пункт 7.9 роадмапа.
- `Theme.qml` — `panelTopRatio` и `panelOpacity` не используются нигде.
- `Panels.qml` — `last` только записывается, чтения нет; удержание содержимого при закрытии делает `Bar.shownKind`.
- `Launcher.qml` — `open` нигде не читается.
- 14 литеральных `opacity` в шести файлах — по правилу AGENTS числа оформления живут только в `Theme.qml`.
- `Tray.qml` — у иконок нет `asynchronous: true` (синхронная загрузка блокирует GUI), хардкод `+ 6` вместо токена, двойная пустая строка.
- Опечатки: `keybinds.kdl` «присета», `layout.kdl` «укарашения» и «Цетрирование».

## Шаги

### Шаг 1. Удалить осиротевший скрипт

```fish
unlink ~/dotfiles/niri/.local/bin/launcher-toggle-mode.fish
```

Проверка:

```fish
test -e ~/dotfiles/niri/.local/bin/launcher-toggle-mode.fish; and echo "остался"; or echo "удалён"
grep -rn "launcherGrid" ~/dotfiles --exclude-dir=.git --exclude=review-fixes-2.md
```

Ожидаемо: `удалён`, вторая команда без вывода (без учёта самой этой md).

### Шаг 2. windowrule.kdl: удалить пустые правила (пункт 7.9)

Файл `niri/.config/niri/windowrule.kdl`. Удалить два блока целиком, включая комментарии.

Блок 1 (wezterm, стоит сразу после правила firefox, пустой строки перед ним нет):

```kdl
window-rule {
    // This regular expression is intentionally made as specific as possible,
    // since this is the default config, and we want no false positives.
    // You can get away with just app-id="wezterm" if you want.
    match app-id=r#"^org\.wezfurlong\.wezterm$"#
    default-column-width {}
}
```

Блок 2 (freshgram, между правилами kitty и zed; удалить вместе с комментарием `// Tg` и одной пустой строкой после `}`, чтобы не осталось двух пустых строк подряд):

```kdl
// Tg
window-rule {
    match app-id="io.github.snowyfluffy.freshgram"


}
```

Проверка:

```fish
niri validate
grep -n "wezterm\|freshgram\|Tg" ~/dotfiles/niri/.config/niri/windowrule.kdl
```

Ожидаемо: `config is valid`, вторая команда без вывода.

### Шаг 3. Theme.qml: убрать мёртвые токены, добавить токены opacity

Файл `niri/.config/quickshell/niri/theme/Theme.qml`. Одна замена:

Было:

```qml
    readonly property int panelWidth: 520
    readonly property int panelPadding: 10
    readonly property real panelTopRatio: 0.2
    readonly property real panelOpacity: 0.85

    readonly property int rowHeight: 34
    readonly property real selectionOpacity: 0.3
```

Стало:

```qml
    readonly property int panelWidth: 520
    readonly property int panelPadding: 10

    readonly property int rowHeight: 34
    readonly property real selectionOpacity: 0.3
    readonly property real dimOpacity: 0.5
    readonly property real softOpacity: 0.7
    readonly property real faintOpacity: 0.3
    readonly property real inactiveOpacity: 0.4
```

Смысл: `dimOpacity` — приглушённый текст (плейсхолдеры, muted, смена состояния строки Wi-Fi), `softOpacity` — подписи второго уровня, `faintOpacity` — неактивные и внешнемесячные, `inactiveOpacity` — приглушённый прогресс при mute.

### Шаг 4. Panels.qml: удалить нечитаемое свойство last

Файл `niri/.config/quickshell/niri/services/Panels.qml` заменить целиком:

```qml
pragma Singleton
import Quickshell

Singleton {
    property string current: ""

    function toggle(name) { current = current === name ? "" : name }
    function close() { current = "" }
}
```

### Шаг 5. Launcher.qml: удалить неиспользуемое open

Файл `niri/.config/quickshell/niri/services/Launcher.qml`.

Было:

```qml
Singleton {
    readonly property bool open: Panels.current === "launcher"

    function toggle() { Panels.toggle("launcher") }
```

Стало:

```qml
Singleton {
    function toggle() { Panels.toggle("launcher") }
```

Проверка: `grep -rn "Launcher.open\|Panels.last" ~/dotfiles/niri/.config/quickshell/niri` — без вывода.

### Шаг 6. Заменить литеральные opacity на токены

Значения не меняются, только подстановка токенов.

**6.1 `components/Volume.qml`** — заменить целиком (добавлен `import qs.theme`):

```qml
import QtQuick
import Quickshell
import qs.theme
import qs.services

Capsule {
    clickable: true
    onClicked: Quickshell.execDetached(["pavucontrol"])
    onScrolled: delta => Audio.changeBy(delta > 0 ? 0.05 : -0.05)

    BarText {
        text: Audio.icon + " " + Audio.percent + "%"
        opacity: Audio.muted ? Theme.dimOpacity : 1
    }
}
```

**6.2 `components/LauncherContent.qml`** — две замены:

```qml
                text: "Поиск приложения"
                opacity: 0.5
                visible: input.text === ""
```
→ `opacity: Theme.dimOpacity`

```qml
                text: "Ничего не найдено"
                opacity: 0.5
                visible: grid.count === 0
```
→ `opacity: Theme.dimOpacity`

**6.3 `components/MediaContent.qml`** — шесть замен:

```qml
                    font.pixelSize: Theme.powerIconSize * 2
                    opacity: 0.5
                    visible: art.status !== Image.Ready
```
→ `opacity: Theme.dimOpacity`

```qml
                    elide: Text.ElideRight
                    opacity: 0.7
                    text: root.player ? root.player.trackArtist : ""
```
→ `opacity: Theme.softOpacity`

```qml
                    opacity: 0.5
                    font.pixelSize: Theme.mediaTimeFontSize
                    text: root.player ? root.player.identity : ""
```
→ `opacity: Theme.dimOpacity`

```qml
                width: Theme.mediaTimeWidth
                opacity: 0.7
                font.pixelSize: Theme.mediaTimeFontSize
                text: root.format(root.position)
```
→ `opacity: Theme.softOpacity`

```qml
                horizontalAlignment: Text.AlignRight
                opacity: 0.7
                font.pixelSize: Theme.mediaTimeFontSize
                text: root.format(root.length)
```
→ `opacity: Theme.softOpacity`

```qml
                        opacity: root.available(modelData) ? 1 : 0.3
```
→ `opacity: root.available(modelData) ? 1 : Theme.faintOpacity`

**6.4 `components/CalendarContent.qml`** — две замены:

```qml
                    verticalAlignment: Text.AlignVCenter
                    opacity: 0.5
                    font.pixelSize: Theme.gridFontSize
```
→ `opacity: Theme.dimOpacity`

```qml
                        opacity: cell.inMonth ? 1 : 0.3
```
→ `opacity: cell.inMonth ? 1 : Theme.faintOpacity`

**6.5 `components/WifiMenuContent.qml`** — одна замена:

```qml
            opacity: network && network.stateChanging ? 0.5 : 1
```
→ `opacity: network && network.stateChanging ? Theme.dimOpacity : 1`

**6.6 `components/VolumeOsdContent.qml`** — две замены:

```qml
                color: Colors.accent
                opacity: Audio.muted ? 0.4 : 1
```
→ `opacity: Audio.muted ? Theme.inactiveOpacity : 1`

```qml
            text: Audio.percent + "%"
            opacity: Audio.muted ? 0.5 : 1
```
→ `opacity: Audio.muted ? Theme.dimOpacity : 1`

Проверка:

```fish
grep -rn "opacity" ~/dotfiles/niri/.config/quickshell/niri/components ~/dotfiles/niri/.config/quickshell/niri/services | grep -E "[0-9]\.[0-9]" | grep -v "Theme\."
```

Ожидаемо: единственная строка — `Bar.qml` с расчётом `Math.max(0, (root.progress - 0.5) * 2)` (это формула, а не стиль).

### Шаг 7. Tray.qml: asynchronous, токен вместо 6, пустая строка

Файл `niri/.config/quickshell/niri/components/Tray.qml`, три замены:

Было:

```qml
import qs.theme



Capsule {
```

Стало:

```qml
import qs.theme

Capsule {
```

Было:

```qml
                sourceSize: Qt.size(Theme.iconSize, Theme.iconSize)
                source: modelData.icon
```

Стало:

```qml
                sourceSize: Qt.size(Theme.iconSize, Theme.iconSize)
                asynchronous: true
                source: modelData.icon
```

Было:

```qml
                    anchor.rect.height: icon.height + 6
```

Стало:

```qml
                    anchor.rect.height: icon.height + Theme.innerSpacing
```

### Шаг 8. Опечатки в комментариях

`niri/.config/niri/keybinds.kdl`, строка 89:

```kdl
    // Смена присета колонок
```
→ `    // Смена пресета колонок`

`niri/.config/niri/layout.kdl`, строка 1:

```kdl
// Отключает укарашения со стороны клиента
```
→ `// Отключает украшения со стороны клиента`

`niri/.config/niri/layout.kdl`, строка 8:

```kdl
    // Цетрирование окна, варианты "never" "always" "on-overflow"
```
→ `    // Центрирование окна, варианты "never" "always" "on-overflow"`

Проверка: `niri validate` → `config is valid`.

### Шаг 9. Роадмап

Файл `niri-rice-roadmap.md`.

9.1. Пункт 4.6 — убрать из описания `Panels.last`.

Было:

```
- [x] 4.6 Основа панелей: единый `Panels` в `services/` + `Loader` в окне бара. `Panels.current` хранит открытую панель, `Panels.last` — последнюю (высота карточки и содержимое не прыгают при закрытии), `Launcher` и `PowerMenu` читают своё состояние оттуда. Панель ленивая (`Loader`), открывается только на мониторе с фокусом, общий стиль (радиус, рамка, отступы из `Theme`), анимация `progress` как у лаунчера
```

Стало:

```
- [x] 4.6 Основа панелей: единый `Panels` в `services/` + `Loader` в окне бара. `Panels.current` хранит открытую панель; высоту карточки и содержимое при закрытии держит `Bar.shownKind`, а `Launcher` и `PowerMenu` управляют панелью через `Panels`. Панель ленивая (`Loader`), открывается только на мониторе с фокусом, общий стиль (радиус, рамка, отступы из `Theme`), анимация `progress` как у лаунчера
```

9.2. Пункт 7.9 — отметить выполненным:

```
- [ ] 7.9 Убрать пустые правила `windowrule.kdl` (wezterm и Telegram без свойств)
```
→
```
- [x] 7.9 Убрать пустые правила `windowrule.kdl` (wezterm и Telegram без свойств)
```

9.3. В «Журнал решений» добавить запись последней строкой, перед пустой строкой и заголовком `## Как обновлять документ`:

```
- Ревью 2026-10-31: удалён мёртвый код — токены `panelTopRatio`/`panelOpacity`, нечитаемые `Panels.last` и `Launcher.open`, осиротевший скрипт `launcher-toggle-mode.fish` (переключал несуществующий `launcherGrid` и не убивал процесс `qs`, потому что команда `pkill quickshell` его не находит), пустые правила `windowrule.kdl` (п. 7.9). Литеральные `opacity` вынесены в токены `Theme` (`dimOpacity`, `softOpacity`, `faintOpacity`, `inactiveOpacity`) с теми же значениями, у иконок трея добавлен `asynchronous: true`. Формула дня недели в календаре проверена на Qt 6.12: `dayName(0)` возвращает воскресенье, бага нет.
```

9.4. Дата в шапке — `Обновлено: 2026-10-31`, уже верная, не менять. Пункт 4.9 не трогать.

### Шаг 10. Проверка

```fish
cd ~/dotfiles
niri validate
pkill -x qs
qs -c niri 2>&1 | tee ~/qs.log &
sleep 6
grep -E "ERROR|undefined|nan|Unable to assign" ~/qs.log
qs -c niri ipc call launcher toggle
sleep 1
qs -c niri ipc call launcher toggle
qs -c niri ipc call calendar toggle
sleep 1
qs -c niri ipc call calendar toggle
qs -c niri ipc call wifi toggle
sleep 1
qs -c niri ipc call wifi toggle
git status --short
```

Лог после перезапуска не должен содержать `ERROR`, `undefined`, `nan`, `Unable to assign` (системные WARN про `sni.watcher`, `qt.qpa.wayland.textinput`, `qt.qpa.services` допустимы). IPC-вызовы отрабатывают без вывода.

Ручная проверка после перезапуска: открыть лаунчер (Mod+Space), календарь (клик по часам) и панель медиа — приглушение текста и плейсхолдеров должно быть прежним, без визуальных отличий.

## Ожидаемый результат

- `niri/.local/bin/launcher-toggle-mode.fish` отсутствует, `grep launcherGrid` по репозиторию пуст.
- `windowrule.kdl` без wezterm и freshgram, `niri validate` — `config is valid`.
- В `Theme.qml` нет `panelTopRatio`/`panelOpacity`, есть `dimOpacity`, `softOpacity`, `faintOpacity`, `inactiveOpacity`.
- `Panels.qml` без `last`, `Launcher.qml` без `open`.
- Литеральных `opacity` с числами в `components/` и `services/` нет (кроме формулы в `Bar.qml`).
- У иконок трея `asynchronous: true`, отступ меню из `Theme.innerSpacing`.
- Опечатки исправлены, роадмап обновлён (4.6, 7.9, журнал), пункт 4.9 не изменён.
- `git status --short` показывает только изменённые шагами файлы; коммит не делать.
