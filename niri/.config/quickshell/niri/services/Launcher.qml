pragma Singleton
import QtQml
import Quickshell
import Quickshell.Io

Singleton {
    function toggle() { Panels.toggle("launcher") }
    function close() { Panels.close() }

    readonly property string genericIcon: Quickshell.iconPath("application-x-executable", true)

    readonly property var iconOverrides: ({
        "hwloc": "/home/sova/.local/share/shelly-icons/src/64x64/hwloc.png",
        "wine": "/home/sova/.local/share/shelly-icons/src/128x128/wine.png",
        "docker": "/home/sova/.local/share/shelly-icons/src/128x128/docker.png"
    })

    readonly property var visibleApps: DesktopEntries.applications.values.filter(e => !e.noDisplay)

    readonly property var tabs: buildTabs()
    readonly property var index: buildIndex()
    readonly property var tabAppIds: buildTabAppIds()

    FileView {
        id: tabsFile
        path: Quickshell.shellPath("launcher/tabs.json")
        watchChanges: true
        onFileChanged: reload()
    }

    FileView {
        id: indexFile
        path: Quickshell.shellPath("launcher/tabs.generated.json")
        watchChanges: true
    }

    Component.onCompleted: ensureIndex()
    onVisibleAppsChanged: ensureIndex()

    function parseJson(text, fallback) {
        if (!text || text.trim() === "") return fallback
        try {
            return JSON.parse(text)
        } catch (e) {
            return fallback
        }
    }

    function buildTabs() {
        const data = parseJson(tabsFile.text(), null)
        if (!data || !data.tabs || data.tabs.length === 0)
            return [{ id: "all", title: "Все", categories: [] }]
        return data.tabs
    }

    function buildIndex() {
        const map = ({})
        for (const entry of visibleApps) {
            for (const category of entry.categories || []) {
                if (!map[category]) map[category] = []
                map[category].push(entry.id)
            }
        }
        return map
    }

    function idsForTab(tab) {
        const ids = ({})
        if (!tab.categories || tab.categories.length === 0) {
            for (const entry of visibleApps) ids[entry.id] = true
        } else {
            for (const category of tab.categories)
                for (const id of (index[category] || []))
                    ids[id] = true
        }
        for (const id of tab.add || []) ids[id] = true
        for (const id of tab.remove || []) delete ids[id]
        return ids
    }

    function buildTabAppIds() {
        const map = ({})
        for (const tab of tabs) map[tab.id] = idsForTab(tab)
        return map
    }

    function matchesTab(entry, tabId) {
        const ids = tabAppIds[tabId]
        return ids ? ids[entry.id] === true : false
    }

    function iconFor(entry) {
        const name = (entry.icon || "").trim()
        const candidates = [name]
        if (name !== "" && name.charAt(0) !== "/") {
            candidates.push("/usr/share/pixmaps/" + name + ".png")
            candidates.push(iconOverrides[name] || "")
        }
        for (const candidate of candidates) {
            if (candidate === "") continue
            const path = Quickshell.iconPath(candidate, true)
            if (path !== "") return path
        }
        return genericIcon
    }

    function search(tabId, query) {
        const apps = visibleApps.filter(e => matchesTab(e, tabId))
        const q = query.trim().toLowerCase()

        if (q === "")
            return apps.sort((a, b) => a.name.localeCompare(b.name))

        const found = []
        for (const e of apps) {
            const name = e.name.toLowerCase()
            let rank = -1
            if (name.startsWith(q)) rank = 0
            else if (name.includes(" " + q)) rank = 1
            else if (name.includes(q)) rank = 2
            else if ((e.genericName || "").toLowerCase().includes(q)
                     || e.keywords.join(" ").toLowerCase().includes(q)) rank = 3
            if (rank >= 0) found.push({ entry: e, rank: rank })
        }
        found.sort((a, b) => a.rank - b.rank || a.entry.name.localeCompare(b.entry.name))
        return found.map(f => f.entry)
    }

    function writeIndex() {
        const data = { version: 1, count: visibleApps.length, categories: buildIndex() }
        indexFile.setText(JSON.stringify(data, null, 2))
    }

    function ensureIndex() {
        const data = parseJson(indexFile.text(), null)
        if (!data || data.count !== visibleApps.length) writeIndex()
    }

    function launch(entry) {
        if (entry.runInTerminal)
            Quickshell.execDetached(["kitty"].concat(entry.command))
        else
            entry.execute()
        close()
    }
}
