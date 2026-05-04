import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.components.effects
import qs.components.controls
import qs.utils

MouseArea {
    id: root

    property bool vertical: Config.bar.vertical
    readonly property bool horizontal: !vertical

    readonly property string hh:    Qt.formatDateTime(Utils.clock.date, "hh")
    readonly property string mm:    Qt.formatDateTime(Utils.clock.date, "mm")
    readonly property string hhmm:  Qt.formatDateTime(Utils.clock.date, "hh:mm")
    readonly property string ddmm:  Qt.formatDateTime(Utils.clock.date, "dd/MM")

    implicitWidth:  horizontal ? hRow.implicitWidth : col.implicitWidth
    implicitHeight: horizontal ? Config.bar.height : col.implicitHeight

    onClicked: popup.active = !popup.active

    // Vertical: stacked hh / mm / dd-MM with rolling digits.
    ColumnLayout {
        id: col
        visible: root.vertical
        anchors.centerIn: parent
        spacing: 6

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: -4

            RollingText {
                Layout.alignment: Qt.AlignHCenter
                text: root.hh
                pixelSize: Config.typography.large
                family: Config.typography.family
                color: Colors.foreground
            }

            RollingText {
                Layout.alignment: Qt.AlignHCenter
                text: root.mm
                pixelSize: Config.typography.large
                family: Config.typography.family
                color: Colors.foreground
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 20
            implicitHeight: 1
            color: Colors.divider
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: root.ddmm
            font.pixelSize: Config.typography.smallest
            font.family: Config.typography.family
            color: Colors.m3onSurfaceInactive
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Horizontal: hh:mm • dd/MM with rolling hh:mm.
    RowLayout {
        id: hRow
        visible: root.horizontal
        anchors.centerIn: parent
        spacing: 6

        RollingText {
            text: root.hhmm
            pixelSize: Config.typography.large
            family: Config.typography.family
            color: Colors.foreground
        }

        StyledText {
            text: "/"
            font.pixelSize: Config.typography.small
            color: Colors.m3onSurfaceInactive
        }

        StyledText {
            text: root.ddmm
            font.pixelSize: Config.typography.small
            font.family: Config.typography.family
            color: Colors.m3onSurfaceInactive
        }
    }

    BarPopup {
        id: popup
        targetItem: root
        padding: 12

        ChoreographerLoader {
            sourceComponent: ChoreographerGridLayout {
                id: popupRoot
                property real buttonSize: 32
                property real buttonSpacing: 4
                rowSpacing: 2
                shown: popup.active

                FlyFadeEnterChoreographable {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 6

                    RowLayout {
                        width: parent.width
                        spacing: 0

                        CrossfadeText {
                            Layout.leftMargin: 6
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            text: calendarView.title
                            pixelSize: Config.typography.large
                            fontWeight: Font.Medium
                            elide: Text.ElideRight
                            color: Colors.accent
                        }

                        RippleButton {
                            implicitWidth: 30
                            implicitHeight: 30
                            buttonRadius: 15
                            onClicked: calendarView.scrollMonthsAndSnap(-1)
                            contentItem: MaterialIcon {
                                text: "chevron_left"
                                pixelSize: 20
                                color: Colors.foreground
                            }
                        }

                        RippleButton {
                            implicitWidth: 30
                            implicitHeight: 30
                            buttonRadius: 15
                            onClicked: calendarView.scrollMonthsAndSnap(1)
                            contentItem: MaterialIcon {
                                text: "chevron_right"
                                pixelSize: 20
                                color: Colors.foreground
                            }
                        }
                    }
                }

                FlyFadeEnterChoreographable {
                    Layout.alignment: Qt.AlignHCenter

                    CalendarDaysOfWeek {
                        locale: calendarView.locale
                        spacing: popupRoot.buttonSpacing
                        delegate: Item {
                            id: dowItem
                            required property var model
                            implicitWidth: popupRoot.buttonSize
                            implicitHeight: dowText.implicitHeight

                            StyledText {
                                id: dowText
                                anchors.centerIn: parent
                                font.pixelSize: Config.typography.smaller
                                color: Colors.m3onSurfaceInactive
                                text: model.shortName.substring(0, 2)
                            }
                        }
                    }
                }

                FlyFadeEnterChoreographable {
                    CalendarView {
                        id: calendarView
                        buttonSize: popupRoot.buttonSize
                        buttonSpacing: popupRoot.buttonSpacing
                        verticalPadding: 4
                        horizontalPadding: 4

                        delegate: RippleButton {
                            id: dayButton
                            required property var model
                            implicitWidth: popupRoot.buttonSize
                            implicitHeight: popupRoot.buttonSize
                            buttonRadius: 8
                            toggled: model.today
                            enabled: model.month === calendarView.focusedMonth
                            
                            contentItem: StyledText {
                                text: model.day
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: dayButton.toggled ? Colors.accentText : (dayButton.enabled ? Colors.foreground : Colors.m3onSurfaceInactive)
                                font.weight: dayButton.toggled ? Font.Bold : Font.Normal
                            }
                        }
                    }
                }
            }
        }
    }
}
