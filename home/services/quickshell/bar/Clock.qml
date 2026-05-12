import QtQuick
import QtQuick.Layouts
import qs.components.surfaces
import qs.components.text
import qs.components.controls
import qs.utils

PressablePill {
    id: root

    property bool vertical: Config.bar.vertical
    readonly property bool horizontal: !vertical

    readonly property string hh:    Qt.formatDateTime(Utils.clock.date, "hh")
    readonly property string mm:    Qt.formatDateTime(Utils.clock.date, "mm")
    readonly property string hhmm:  Qt.formatDateTime(Utils.clock.date, "hh:mm")
    readonly property string ddmm:  Qt.formatDateTime(Utils.clock.date, "dd/MM")

    implicitWidth:  horizontal ? hRow.implicitWidth + 16 : Config.bar.width - Config.layout.gapSm * 2
    implicitHeight: horizontal ? Config.bar.height - Config.layout.gapSm * 2 : col.implicitHeight + 8

    radius: Config.layout.radiusContainer
    colorIdle: horizontal ? Appearance.colors.surfaceContainerLow : Appearance.colors.transparent
    useStateLayer: true
    pressScale: 0.98

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
                color: Appearance.colors.foreground
            }

            RollingText {
                Layout.alignment: Qt.AlignHCenter
                text: root.mm
                pixelSize: Config.typography.large
                family: Config.typography.family
                color: Appearance.colors.foreground
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 20
            implicitHeight: 1
            color: Appearance.colors.divider
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: root.ddmm
            font.pixelSize: Config.typography.smallest
            font.family: Config.typography.family
            color: Appearance.colors.m3onSurfaceInactive
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
            color: Appearance.colors.foreground
        }

        StyledText {
            text: "/"
            font.pixelSize: Config.typography.small
            color: Appearance.colors.m3onSurfaceInactive
        }

        StyledText {
            text: root.ddmm
            font.pixelSize: Config.typography.small
            font.family: Config.typography.family
            color: Appearance.colors.m3onSurfaceInactive
        }
    }

    BarPopup {
        id: popup
        targetItem: root
        padding: 12

        CalendarPanel { active: popup.active }
    }
}
