import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.modules.common.widgets
import qs.modules.common

HoverTooltip {
    id: root

    property bool vertical: Config.bar.vertical
    property string cluster: "solo"

    readonly property bool _roundStart: cluster === "start" || cluster === "solo"
    readonly property bool _roundEnd:   cluster === "end"   || cluster === "solo"
    readonly property bool _roundTL: vertical ? _roundStart : _roundStart
    readonly property bool _roundTR: vertical ? _roundStart : _roundEnd
    readonly property bool _roundBL: vertical ? _roundEnd   : _roundStart
    readonly property bool _roundBR: vertical ? _roundEnd   : _roundEnd

    readonly property var  battery:    UPower.displayDevice
    readonly property int  percentage: Math.round(battery.percentage * 100)
    readonly property real fraction:   Math.max(0, Math.min(1, battery.percentage))
    readonly property bool charging:   battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.FullyCharged
    readonly property bool low: visible && fraction <= 0.20 && !charging

    visible: battery.isLaptopBattery

    text: `Battery ${percentage}%${charging ? " (charging)" : ""}`

    implicitWidth:  vertical
        ? Appearance.bar.width
        : (hRow.implicitWidth + Appearance.layout.gapMd * 2)
    implicitHeight: vertical
        ? (vCol.implicitHeight + Appearance.layout.gapMd)
        : Appearance.bar.height

    Rectangle {
        anchors.fill: parent
        anchors.topMargin:    root.vertical ? 0 : Appearance.layout.gapSm
        anchors.bottomMargin: root.vertical ? 0 : Appearance.layout.gapSm
        anchors.leftMargin:   root.vertical ? Appearance.layout.gapSm : 0
        anchors.rightMargin:  root.vertical ? Appearance.layout.gapSm : 0
        topLeftRadius:     root._roundTL ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        topRightRadius:    root._roundTR ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        bottomLeftRadius:  root._roundBL ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        bottomRightRadius: root._roundBR ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        color: Appearance.colors.surfaceContainerLow
    }

    Row {
        id: hRow
        visible: !root.vertical
        anchors.centerIn: parent
        spacing: Appearance.layout.gapSm

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: `${root.percentage}%`
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.small
            color: Appearance.colors.foreground
        }

        BatteryHorizontal {
            anchors.verticalCenter: parent.verticalCenter
            fraction: root.fraction
            charging: root.charging
            low: root.low
        }
    }

    ColumnLayout {
        id: vCol
        visible: root.vertical
        anchors.centerIn: parent
        spacing: 4

        BatteryHorizontal {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: tipGap + tipH
            fraction: root.fraction
            charging: root.charging
            low: root.low
            bodyW: 12
            bodyH: 22
            bodyR: 4
            innerPad: 2
            tipGap: 1
            tipW: 6
            tipH: 2
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 20
            implicitHeight: 1
            color: Appearance.colors.divider
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 22
            text: `${root.percentage}%`
            horizontalAlignment: Text.AlignHCenter
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.smallest
            color: Appearance.colors.m3onSurfaceInactive
        }
    }
}
