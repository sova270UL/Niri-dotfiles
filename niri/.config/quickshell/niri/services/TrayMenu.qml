pragma Singleton
import QtQml
import Quickshell

Singleton {
    id: root

    property var item: null
    property var anchorItem: null
    property var popup: null

    readonly property bool open: popup !== null
    readonly property var entries: opener.children
    readonly property var rows: buildRows(entries ? entries.values : [])

    QsMenuOpener {
        id: opener
        menu: root.item ? root.item.menu : null
    }

    Connections {
        target: Panels
        function onCurrentChanged() {
            if (Panels.current !== "") root.close()
        }
    }

    function buildRows(values) {
        const result = []
        let separator = false
        for (const entry of values) {
            if (entry.isSeparator) {
                separator = true
                continue
            }
            result.push({ entry: entry, separator: separator })
            separator = false
        }
        return result
    }

    function show(trayItem, anchor, window) {
        Panels.close()
        item = trayItem
        anchorItem = anchor
        popup = window
    }

    function close() {
        popup = null
        anchorItem = null
        item = null
    }

    function activate(entry) {
        if (!entry.enabled) return
        entry.triggered()
        close()
    }

    function submenu(entry, x, y) {
        entry.display(popup, x, y)
    }
}
