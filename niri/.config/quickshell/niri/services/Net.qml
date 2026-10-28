pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var devices: Networking.devices.values

    readonly property var wired: devices.find(
        d => d.type === DeviceType.Wired && d.connected) || null
    readonly property var wifiDevice: devices.find(
        d => d.type === DeviceType.Wifi) || null
    readonly property var wifi: devices.find(
        d => d.type === DeviceType.Wifi && d.connected) || null

    readonly property var wifiNetwork: wifi
        ? (wifi.networks.values.find(n => n.connected) || null) : null

    readonly property real strength: wifiNetwork ? wifiNetwork.signalStrength : 0

    function wifiIcon(s) {
        if (s < 0.25) return "󰤟"
        if (s < 0.50) return "󰤢"
        if (s < 0.75) return "󰤥"
        return "󰤨"
    }

    readonly property string icon: {
        if (wired) return "󰈀"
        if (wifi) return wifiIcon(strength)
        return "󰀦"
    }

    readonly property bool online: wired !== null || wifi !== null
}
