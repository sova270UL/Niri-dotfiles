pragma Singleton
import Quickshell

Singleton {
    readonly property bool open: Panels.current === "launcher"

    function toggle() { Panels.toggle("launcher") }
    function close() { Panels.close() }

    function search(query) {
        const apps = DesktopEntries.applications.values.filter(e => !e.noDisplay)
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

    function launch(entry) {
        if (entry.runInTerminal)
            Quickshell.execDetached(["kitty"].concat(entry.command))
        else
            entry.execute()
        close()
    }
}