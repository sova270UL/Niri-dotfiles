pragma Singleton
import Quickshell

Singleton {
    readonly property bool open: Panels.current === "launcher"

    function toggle() { Panels.toggle("launcher") }
    function close() { Panels.close() }

    readonly property string genericIcon: Quickshell.iconPath("application-x-executable", true)

    readonly property var iconOverrides: ({
        "hwloc": "/home/sova/.local/share/shelly-icons/src/64x64/hwloc.png",
        "wine": "/home/sova/.local/share/shelly-icons/src/128x128/wine.png",
        "docker": "/home/sova/.local/share/shelly-icons/src/128x128/docker.png"
    })

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