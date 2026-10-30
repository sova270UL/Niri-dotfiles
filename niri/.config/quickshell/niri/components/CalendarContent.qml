import QtQuick
import Quickshell
import qs.theme
import qs.services

Item {
    id: root
    focus: true

    property int year: clock.date.getFullYear()
    property int month: clock.date.getMonth()

    readonly property int firstDay: Qt.locale().firstDayOfWeek % 7
    readonly property int offset: (new Date(year, month, 1).getDay() - firstDay + 7) % 7
    readonly property string title: {
        const name = Qt.locale().monthName(month, Locale.LongFormat)
        return name.charAt(0).toUpperCase() + name.slice(1) + " " + year
    }

    function shift(delta) {
        const d = new Date(year, month + delta, 1)
        year = d.getFullYear()
        month = d.getMonth()
    }

    function reset() {
        year = clock.date.getFullYear()
        month = clock.date.getMonth()
    }

    function isToday(d) {
        const t = clock.date
        return d.getFullYear() === t.getFullYear()
            && d.getMonth() === t.getMonth()
            && d.getDate() === t.getDate()
    }

    Component.onCompleted: forceActiveFocus()

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            Panels.close()
        } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H || event.key === Qt.Key_PageUp) {
            shift(-1)
        } else if (event.key === Qt.Key_Right || event.key === Qt.Key_L || event.key === Qt.Key_PageDown) {
            shift(1)
        } else if (event.key === Qt.Key_T || event.key === Qt.Key_Home) {
            reset()
        } else {
            return
        }
        event.accepted = true
    }

    SystemClock {
        id: clock
        precision: SystemClock.Hours
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => root.shift(wheel.angleDelta.y > 0 ? -1 : 1)
    }

    Column {
        anchors.fill: parent
        spacing: Theme.spacing

        Item {
            width: parent.width
            height: Theme.rowHeight

            Rectangle {
                id: prev
                width: Theme.rowHeight
                height: parent.height
                radius: Theme.radius
                color: Qt.alpha(Colors.accent, prevMouse.containsMouse ? Theme.selectionOpacity : 0)

                Behavior on color { ColorAnimation { duration: Theme.animationMs } }

                BarText { anchors.centerIn: parent; text: "" }

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.shift(-1)
                }
            }

            Rectangle {
                anchors.left: prev.right
                anchors.right: next.left
                height: parent.height
                radius: Theme.radius
                color: Qt.alpha(Colors.accent, titleMouse.containsMouse ? Theme.selectionOpacity : 0)

                Behavior on color { ColorAnimation { duration: Theme.animationMs } }

                BarText {
                    anchors.centerIn: parent
                    font.bold: true
                    text: root.title
                }

                MouseArea {
                    id: titleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.reset()
                }
            }

            Rectangle {
                id: next
                anchors.right: parent.right
                width: Theme.rowHeight
                height: parent.height
                radius: Theme.radius
                color: Qt.alpha(Colors.accent, nextMouse.containsMouse ? Theme.selectionOpacity : 0)

                Behavior on color { ColorAnimation { duration: Theme.animationMs } }

                BarText { anchors.centerIn: parent; text: "" }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.shift(1)
                }
            }
        }

        Row {
            width: parent.width
            height: Theme.calendarWeekdayHeight

            Repeater {
                model: 7

                BarText {
                    required property int index
                    width: Theme.calendarCell
                    height: Theme.calendarWeekdayHeight
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    opacity: 0.5
                    font.pixelSize: Theme.gridFontSize
                    text: Qt.locale().dayName((root.firstDay + index) % 7, Locale.ShortFormat)
                }
            }
        }

        Grid {
            columns: 7

            Repeater {
                model: 42

                Rectangle {
                    id: cell
                    required property int index
                    readonly property var day: new Date(root.year, root.month, 1 - root.offset + index)
                    readonly property bool today: root.isToday(day)
                    readonly property bool inMonth: day.getMonth() === root.month

                    width: Theme.calendarCell
                    height: Theme.calendarCell
                    radius: Theme.radius
                    color: today ? Colors.accent : "transparent"

                    BarText {
                        anchors.centerIn: parent
                        text: cell.day.getDate()
                        color: cell.today ? Colors.background : Colors.foreground
                        opacity: cell.inMonth ? 1 : 0.3
                        font.bold: cell.today
                    }
                }
            }
        }
    }
}
