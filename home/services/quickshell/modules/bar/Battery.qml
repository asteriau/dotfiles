import QtQuick
import Quickshell.Services.UPower
import qs.modules.common.widgets
import qs.modules.common

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

            Loader {
                anchors.centerIn: parent
                sourceComponent: root.vertical ? verticalIndicator : horizontalIndicator
            }

            Component {
                id: verticalIndicator
                BatteryVertical {
                    icon: root.batteryIcon
                    percentage: root.percentage
                }
            }
            Component {
                id: horizontalIndicator
                BatteryHorizontal {
                    icon: root.batteryIcon
                    percentage: root.percentage
                }
            }
        }
    }
}
