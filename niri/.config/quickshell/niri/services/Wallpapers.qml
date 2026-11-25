pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: home + "/.local/state/niri-wall"
    readonly property string settingsPath: stateDir + "/settings.json"
    readonly property string defaultDirectory: home + "/Изображения"
    readonly property string script: home + "/.local/bin/set-wall.fish"
    readonly property string displayDirectory: directory === home
        ? "~"
        : directory.startsWith(home + "/") ? "~" + directory.slice(home.length) : directory

    property string directory: defaultDirectory
    property var images: []
    property bool loading: false
    property bool applying: false
    property string current: ""
    property string pendingDirectory: ""
    property bool scanQueued: false

    signal directoryAccepted()
    signal directoryRejected()

    function parseSettings(text) {
        if (!text || text.trim() === "") return null
        try {
            return JSON.parse(text)
        } catch (e) {
            return null
        }
    }

    function readSettings() {
        const data = parseSettings(settingsFile.text())
        const dir = data && typeof data.directory === "string" ? data.directory : defaultDirectory
        if (dir !== root.directory) {
            root.directory = dir
            root.scan()
        }
    }

    function saveSettings() {
        settingsFile.setText(JSON.stringify({ directory: root.directory }, null, 2))
    }

    function scan() {
        if (scanProcess.running) {
            root.scanQueued = true
            return
        }
        root.loading = true
        scanProcess.command = ["find", root.directory, "-type", "f", "(", "-iname", "*.jpg",
            "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp",
            ")", "-not", "-path", "*/.*", "-print0"]
        scanProcess.running = true
    }

    function finishScan(text, code) {
        const paths = text.split("\0").filter(path => path !== "")
        paths.sort((a, b) => a.localeCompare(b))
        root.images = paths
        root.loading = false
        if (code !== 0 && paths.length === 0)
            console.warn("wallpaper: не удалось прочитать каталог", root.directory, scanErr.text.trim())
    }

    function requestDirectory(path) {
        let resolved = (path || "").trim()
        if (resolved === "~") resolved = root.home
        else if (resolved.startsWith("~/")) resolved = root.home + resolved.slice(1)
        if (resolved === "" || resolved.charAt(0) !== "/") {
            root.directoryRejected()
            return
        }
        if (dirCheck.running) return
        root.pendingDirectory = resolved
        dirCheck.command = ["realpath", "-e", "--", resolved]
        dirCheck.running = true
    }

    function apply(path) {
        if (root.applying || !path) return false
        root.applying = true
        applyProcess.command = [root.script, path]
        applyProcess.running = true
        return true
    }

    Component.onCompleted: {
        root.readSettings()
        root.scan()
    }

    FileView {
        id: settingsFile
        path: root.settingsPath
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.readSettings()
        onSaveFailed: error => console.warn("wallpaper: не удалось сохранить настройки", error)
    }

    FileView {
        id: currentFile
        path: root.stateDir + "/current"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.current = text().trim()
    }

    Process {
        id: stateDirProcess
        command: ["mkdir", "-p", root.stateDir]
        running: true
    }

    Process {
        id: scanProcess
        stderr: StdioCollector { id: scanErr }
        onExited: code => {
            if (root.scanQueued) {
                root.scanQueued = false
                root.scan()
                return
            }
            root.finishScan(scanOut.text, code)
        }
        stdout: StdioCollector { id: scanOut; waitForEnd: true }
    }

    Process {
        id: dirCheck
        stdout: StdioCollector { id: dirOut; waitForEnd: true }
        onExited: code => {
            if (code !== 0) {
                root.directoryRejected()
                return
            }
            const resolved = dirOut.text.trim()
            if (resolved === "") {
                root.directoryRejected()
                return
            }
            root.directory = resolved
            root.saveSettings()
            root.scan()
            root.directoryAccepted()
        }
    }

    Process {
        id: applyProcess
        stderr: StdioCollector { id: applyErr; waitForEnd: true }
        onExited: code => {
            root.applying = false
            if (code !== 0)
                console.warn("wallpaper: set-wall завершился с ошибкой", code, applyErr.text.trim())
        }
    }
}
