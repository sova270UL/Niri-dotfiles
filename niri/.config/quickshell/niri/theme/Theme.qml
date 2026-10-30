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

    readonly property int workspaceDotWidth: 10
    readonly property int workspaceActiveWidth: 15
    readonly property int workspaceDotHeight: 8
    readonly property int workspaceSpacing: 6
    readonly property real workspaceInactiveOpacity: 0.4

    readonly property int panelWidth: 520
    readonly property int panelPadding: 10
    readonly property real panelTopRatio: 0.2
    readonly property real panelOpacity: 0.85

    readonly property int rowHeight: 34
    readonly property real selectionOpacity: 0.3

    readonly property int gridColumns: 5
    readonly property int gridRows: 4
    readonly property int gridCellWidth: Math.floor((panelWidth - panelPadding * 2) / gridColumns)
    readonly property int gridCellHeight: 96
    readonly property int gridCellPadding: 8
    readonly property int gridIconSize: 40
    readonly property int gridFontSize: 12

    readonly property int powerItems: 3
    readonly property int powerIconSize: 18
    readonly property int powerMenuHeight: spacing * 2 + rowHeight * powerItems + spacing * (powerItems - 1)

    readonly property int wifiRows: 6
    readonly property int wifiPanelWidth: 260
    readonly property int wifiPanelHeight: spacing * 2 + rowHeight * (wifiRows + 2)
    readonly property int wifiScanMs: 10000
    readonly property int wifiRefreshMs: 4000
    readonly property real wifiMinStrength: 0.1

    readonly property int osdWidth: 220
    readonly property int osdHeight: spacing * 2 + rowHeight
    readonly property int osdIconSize: 18
    readonly property int osdTrackHeight: 6
    readonly property int osdPercentWidth: 40
    readonly property int osdBottomMargin: 64
    readonly property int osdHideMs: 1500
    readonly property int osdArmMs: 1500
    readonly property int fullscreenTolerance: 2

    readonly property int mediaCoverSize: 72
    readonly property int mediaTrackHeight: 6
    readonly property int mediaProgressHeight: 18
    readonly property int mediaTimeWidth: 36
    readonly property int mediaTimeFontSize: 12
    readonly property int mediaButtonWidth: 48
    readonly property int mediaPanelWidth: 300
    readonly property int mediaPanelHeight: spacing * 2 + mediaCoverSize + spacing + mediaProgressHeight + spacing + rowHeight
    readonly property int mediaBarMaxWidth: 180
    readonly property int mediaTickMs: 1000
    readonly property string visualizerPreset: "bottom"
    readonly property bool visualizerRequirePlayback: true
    readonly property int visualizerHeight: 240
    readonly property int visualizerGap: 4
    readonly property int visualizerMinBar: 4
    readonly property real visualizerMinOpacity: 0.3
    readonly property int visualizerMaxRange: 1000
    readonly property int visualizerFadeMs: 500
    readonly property int visualizerSmoothMs: 60

    readonly property int calendarCell: 36
    readonly property int calendarWeekdayHeight: 22
    readonly property int calendarWidth: calendarCell * 7 + spacing * 2
    readonly property int calendarHeight: spacing * 4 + rowHeight + calendarWeekdayHeight + calendarCell * 6

    readonly property int launcherHeight: panelPadding * 2 + rowHeight + spacing + gridCellHeight * gridRows
    readonly property int launcherMs: 260
    readonly property real launcherOpacity: 0.85

    readonly property int animationMs: 150
}
