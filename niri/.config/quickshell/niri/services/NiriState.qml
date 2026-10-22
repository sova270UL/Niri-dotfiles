pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var workspaces: []
    property var layouts: []
    property int layoutIdx: 0
    readonly property string layoutCode: layouts.length > 0
        ? layouts[layoutIdx].slice(0, 2).toUpperCase() : ""

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
        }
    }

    Process {
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: line => root.handle(JSON.parse(line))
        }
    }
}
