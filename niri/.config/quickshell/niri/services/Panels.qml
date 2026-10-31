pragma Singleton
import Quickshell

Singleton {
    property string current: ""

    function toggle(name) { current = current === name ? "" : name }
    function close() { current = "" }
}
