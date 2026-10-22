pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property var devices: Networking.devices.values

    readonly property var wired: devices.find(
        d => d.type === DeviceType.Wired && d.connected) || null
    readonly property var wifi: devices.find(
        d => d.type === DeviceType.Wifi && d.connected) || null

    readonly property var wifiNetwork: wifi
        ? (wifi.networks.values.find(n => n.connected) || null) : null

    readonly property real strength: wifiNetwork ? wifiNetwork.signalStrength : 0

    readonly property string icon: {
        if (wired) return "\uDB80\uDE00"
        if (wifi) {
            if (strength < 0.25) return "\uDB82\uDD1F"
            if (strength < 0.50) return "\uDB82\uDD22"
            if (strength < 0.75) return "\uDB82\uDD25"
            return "\uDB82\uDD28"
        }
        return "\uDB80\uDC26"
    }

    readonly property bool online: wired !== null || wifi !== null
}
