pragma Singleton
import Quickshell

Singleton {
    readonly property string fontFamily: "Noto Sans Mono"
    readonly property int fontSize: 14
    readonly property int iconSize: 14

    readonly property int radius: 9
    readonly property int borderWidth: 2
    readonly property int gap: 7
    readonly property int spacing: 5
    readonly property int innerSpacing: 6

    readonly property int barHeight: 25
    readonly property int barMargin: 4
    readonly property real barOpacity: 0.5

    readonly property int capsuleHeight: 17
    readonly property int capsulePadding: 10
    readonly property real capsuleOpacity: 0.12
    readonly property real capsuleHoverOpacity: 0.24

    readonly property int animationMs: 150
}
