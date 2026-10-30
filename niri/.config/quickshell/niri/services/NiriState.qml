pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.theme

Singleton {
    id: root

    property var workspaces: []
    property var windows: ({})
    property var layouts: []
    property int layoutIdx: 0
    readonly property string layoutCode: layouts.length > 0
        ? layouts[layoutIdx].slice(0, 2).toUpperCase() : ""

    readonly property string focusedOutput: {
        const w = workspaces.find(w => w.is_focused)
        return w ? w.output : ""
    }

    readonly property bool focusedFullscreen: {
        const win = Object.values(windows).find(w => w.is_focused)
        if (!win || !win.layout) return false
        const ws = workspaces.find(w => w.id === win.workspace_id)
        const screen = ws ? Quickshell.screens.find(s => s.name === ws.output) : null
        if (!screen) return false
        const size = win.layout.tile_size
        return size[0] >= screen.width - Theme.fullscreenTolerance
            && size[1] >= screen.height - Theme.fullscreenTolerance
    }

    function hasWindows(workspaceId) {
        return Object.values(windows).some(w => w.workspace_id === workspaceId)
    }

    function emptyWorkspace(output) {
        const ws = workspaces.find(w => w.output === output && w.is_active)
        return ws !== undefined && !hasWindows(ws.id)
    }

    readonly property bool anyEmptyWorkspace: workspaces.some(w => w.is_active && !hasWindows(w.id))

    function workspacesFor(output) {
        return workspaces
            .filter(w => w.output === output)
            .sort((a, b) => a.idx - b.idx)
    }

    function handle(event) {
        if (event.WorkspacesChanged) {
            workspaces = event.WorkspacesChanged.workspaces
        } else if (event.WorkspaceActivated) {
            const ev = event.WorkspaceActivated
            const target = workspaces.find(w => w.id === ev.id)
            if (!target) return
            workspaces = workspaces.map(w => {
                const copy = Object.assign({}, w)
                if (w.output === target.output) copy.is_active = (w.id === ev.id)
                if (ev.focused) copy.is_focused = (w.id === ev.id)
                return copy
            })
        } else if (event.KeyboardLayoutsChanged) {
            const k = event.KeyboardLayoutsChanged.keyboard_layouts
            layouts = k.names
            layoutIdx = k.current_idx
        } else if (event.KeyboardLayoutSwitched) {
            layoutIdx = event.KeyboardLayoutSwitched.idx
        } else if (event.WindowsChanged) {
            const map = {}
            for (const w of event.WindowsChanged.windows) map[w.id] = w
            windows = map
        } else if (event.WindowOpenedOrChanged) {
            const w = event.WindowOpenedOrChanged.window
            const map = {}
            for (const k in windows)
                map[k] = w.is_focused ? Object.assign({}, windows[k], { is_focused: false }) : windows[k]
            map[w.id] = w
            windows = map
        } else if (event.WindowClosed) {
            const map = Object.assign({}, windows)
            delete map[event.WindowClosed.id]
            windows = map
        } else if (event.WindowFocusChanged) {
            const id = event.WindowFocusChanged.id
            const map = {}
            for (const k in windows)
                map[k] = Object.assign({}, windows[k], { is_focused: id !== null && Number(k) === id })
            windows = map
        } else if (event.WindowLayoutsChanged) {
            const map = Object.assign({}, windows)
            for (const change of event.WindowLayoutsChanged.changes) {
                const id = change[0]
                if (map[id]) map[id] = Object.assign({}, map[id], { layout: change[1] })
            }
            windows = map
        }
    }

    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    root.handle(JSON.parse(line))
                } catch (e) {
                    console.warn("NiriState: bad event line:", e)
                }
            }
        }
    }
}
