import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.modules.bar.popups

PressablePill {
    id: root

    property bool vertical: Config.bar.vertical
    readonly property bool horizontal: !vertical

    property string cluster: "solo"

    readonly property bool _roundLeft:  cluster === "start" || cluster === "solo"
    readonly property bool _roundRight: cluster === "end"   || cluster === "solo"

    readonly property string hh:    Qt.formatDateTime(Utils.clock.date, "hh")
    readonly property string mm:    Qt.formatDateTime(Utils.clock.date, "mm")
    readonly property string hhmm:  Qt.formatDateTime(Utils.clock.date, "hh:mm")
    readonly property string ddmm:  Qt.formatDateTime(Utils.clock.date, "dd/MM")

    implicitWidth:  horizontal ? hRow.implicitWidth + 16 : Appearance.bar.width - Appearance.layout.gapSm * 2
    implicitHeight: horizontal ? Appearance.bar.height - Appearance.layout.gapSm * 2 : col.implicitHeight + 8

    radius: Appearance.layout.radiusContainer
    topLeftRadius:     _roundLeft  ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    bottomLeftRadius:  _roundLeft  ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    topRightRadius:    _roundRight ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    bottomRightRadius: _roundRight ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
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
                pixelSize: Appearance.typography.large
                family: Config.typography.family
                color: Appearance.colors.foreground
            }

            RollingText {
                Layout.alignment: Qt.AlignHCenter
                text: root.mm
                pixelSize: Appearance.typography.large
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
            font.pixelSize: Appearance.typography.smallest
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
            pixelSize: Appearance.typography.large
            family: Config.typography.family
            color: Appearance.colors.foreground
        }


        StyledText {
            text: root.ddmm
            font.pixelSize: Appearance.typography.small
            font.family: Config.typography.family
            color: Appearance.colors.m3onSurfaceInactive
        }
    }

    BarPopup {
        id: popup
        targetItem: root
        padding: Appearance.layout.gapLg

        CalendarPopup { active: popup.active }
    }
}
