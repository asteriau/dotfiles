import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.components.effects
import qs.components.text
import qs.utils

// Shared month-grid calendar — used by Clock's popup and the expanded-bar
// clock content. Choreographed on first show.
ChoreographerLoader {
    id: root

    property bool active: true

    sourceComponent: ChoreographerGridLayout {
        id: popupRoot
        property real buttonSize:    32
        property real buttonSpacing: 4
        rowSpacing: 2
        shown: root.active

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
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
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
                buttonSize:        popupRoot.buttonSize
                buttonSpacing:     popupRoot.buttonSpacing
                verticalPadding:   4
                horizontalPadding: 4

                delegate: RippleButton {
                    id: dayButton
                    required property var model
                    implicitWidth:  popupRoot.buttonSize
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
