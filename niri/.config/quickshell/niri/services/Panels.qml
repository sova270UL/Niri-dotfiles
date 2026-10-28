pragma Singleton
import Quickshell

Singleton {
    property string current: ""
    property string last: "launcher"

    onCurrentChanged: if (current !== "") last = current

    function toggle(name) { current = current === name ? "" : name }
    function close() { current = "" }
}