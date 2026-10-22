pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import "../sidebarRight/calendar/calendar_layout.js" as CalendarLayout
import QtQuick
import QtQuick.Layouts

// Same skeleton as ResourcesPopup/WeatherPopup: header row, then a 7-column grid
// (claude.ai/design "Calendar Popup"). The sidebar CalendarWidget keeps its own look.
StyledPopup {
    id: root

    property int monthShift: 0
    readonly property var viewingDate: CalendarLayout.getDateInXMonthsTime(monthShift)
    readonly property var calendarLayout: CalendarLayout.getCalendarLayout(viewingDate, monthShift === 0)

    // StyledPopup sizes itself from implicit sizes, which a ColumnLayout with
    // fillWidth rows underreports, so the width is pinned here (like Resources)
    Item {
        anchors.centerIn: parent
        implicitWidth: 280
        implicitHeight: column.implicitHeight

        MouseArea {
            anchors.fill: parent
            onWheel: event => root.monthShift += event.angleDelta.y > 0 ? -1 : 1
        }

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    Layout.fillWidth: true
                    text: root.viewingDate.toLocaleDateString(Qt.locale(), "MMMM yyyy")
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.weight: Font.Medium
                    color: Appearance.colors.colPrimary
                }
                RippleButton {
                    visible: root.monthShift !== 0
                    implicitWidth: todayLabel.implicitWidth + 20
                    implicitHeight: 26
                    buttonRadius: Appearance.rounding.full
                    downAction: () => root.monthShift = 0
                    contentItem: StyledText {
                        id: todayLabel
                        text: Translation.tr("Today")
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: Appearance.font.pixelSize.smallie
                        color: Appearance.colors.colSubtext
                    }
                }
                RippleButton {
                    implicitWidth: 26
                    implicitHeight: 26
                    buttonRadius: Appearance.rounding.full
                    downAction: () => root.monthShift--
                    contentItem: MaterialSymbol {
                        text: "chevron_left"
                        iconSize: Appearance.font.pixelSize.larger
                        horizontalAlignment: Text.AlignHCenter
                        color: Appearance.colors.colOnLayer1
                    }
                }
                RippleButton {
                    implicitWidth: 26
                    implicitHeight: 26
                    buttonRadius: Appearance.rounding.full
                    downAction: () => root.monthShift++
                    contentItem: MaterialSymbol {
                        text: "chevron_right"
                        iconSize: Appearance.font.pixelSize.larger
                        horizontalAlignment: Text.AlignHCenter
                        color: Appearance.colors.colOnLayer1
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 0
                    uniformCellWidths: true

                    Repeater {
                        model: CalendarLayout.weekDays
                        StyledText {
                            required property var modelData
                            Layout.fillWidth: true
                            text: Translation.tr(modelData.day)
                            horizontalAlignment: Text.AlignHCenter
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colSubtext
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 2
                    rowSpacing: 2
                    uniformCellWidths: true

                    Repeater {
                        model: [].concat(...root.calendarLayout) // QML JS has no Array.flat
                        RippleButton {
                            id: dayButton
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 30
                            toggled: modelData.today === 1
                            buttonRadius: Appearance.rounding.small
                            buttonRadiusPressed: Appearance.rounding.verysmall
                            contentItem: StyledText {
                                anchors.fill: parent
                                text: dayButton.modelData.day
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: dayButton.toggled ? Font.Medium : Font.Normal
                                color: dayButton.toggled ? Appearance.m3colors.m3onPrimary
                                    : dayButton.modelData.today === 0 ? Appearance.colors.colOnLayer1
                                    : Appearance.colors.colOutlineVariant
                            }
                        }
                    }
                }
            }
        }
    }
}
