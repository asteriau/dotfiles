import QtQuick
import Quickshell.Services.UPower
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

HoverTooltip {
    id: root

    property bool vertical: Config.bar.vertical

    readonly property var  battery:    UPower.displayDevice
    readonly property int  percentage: Math.round(battery.percentage * 100)
    readonly property real fraction:   Math.max(0, Math.min(1, battery.percentage))
    readonly property bool charging:   battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.FullyCharged
    readonly property bool low: visible && fraction <= 0.20 && !charging
    readonly property string batteryIcon: charging ? "bolt"
        : `battery_${Math.round(fraction * 6)}_bar`

    visible: battery.isLaptopBattery

    text: `Battery ${percentage}%${charging ? " (charging)" : ""}`

    implicitWidth:  bar.implicitWidth
    implicitHeight: bar.implicitHeight

    ClippedProgressBar {
        id: bar
        vertical: root.vertical
        value: root.fraction
        valueBarWidth:  root.vertical ? 20 : 38
        valueBarHeight: root.vertical ? 36 : 18
        highlightColor: root.low ? Appearance.colors.red : Appearance.colors.m3onSecondaryContainer

        Item {
            width:  bar.valueBarWidth
            height: bar.valueBarHeight

            Column {
                visible: root.vertical
                anchors.centerIn: parent
                spacing: -4

                MaterialIcon {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.batteryIcon
                    fill: 1
                    pixelSize: Appearance.typography.normal
                    weight: Font.DemiBold
                    color: "white"
                }
                Text {
                    visible: root.percentage < 100
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: `${root.percentage}`
                    font.family: Config.typography.family
                    font.pixelSize: Appearance.typography.smallie
                    font.weight: Font.DemiBold
                    color: "white"
                }
            }

            Row {
                visible: !root.vertical
                anchors.centerIn: parent
                spacing: 1

                MaterialIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.batteryIcon
                    fill: 1
                    pixelSize: 11
                    weight: Font.DemiBold
                    color: "white"
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: `${root.percentage}`
                    font.family: Config.typography.family
                    font.pixelSize: Appearance.typography.smallie
                    font.weight: root.percentage < 100 ? Font.DemiBold : Font.Medium
                    color: "white"
                }
            }
        }
    }
}
