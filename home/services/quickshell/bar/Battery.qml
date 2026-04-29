import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower
import qs.components.controls
import qs.components.effects
import qs.components.text
import qs.utils

HoverTooltip {
    id: root

    property bool vertical: Config.bar.vertical

    readonly property var  battery: UPower.displayDevice
    readonly property int  percentage: Math.round(battery.percentage * 100)
    readonly property real fraction: Math.max(0, Math.min(1, battery.percentage))
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.FullyCharged
    readonly property bool low: fraction <= 0.20 && !charging

    visible: battery.isLaptopBattery

    text: `Battery ${percentage}%${charging ? " (charging)" : ""}`

    implicitWidth:  vertical ? 20 : hRow.implicitWidth
    implicitHeight: vertical ? 20 : hRow.implicitHeight

    CircularProgress {
        id: vCirc
        visible: root.vertical
        anchors.centerIn: parent
        value: root.fraction
        color: root.low ? Colors.red : Colors.m3onSecondaryContainer

        Item {
            anchors.centerIn: parent
            width: vCirc.implicitSize
            height: vCirc.implicitSize
            MaterialIcon {
                anchors.centerIn: parent
                text: root.charging ? "bolt" : "battery_full"
                fill: 1
                pixelSize: 13
                weight: Font.DemiBold
                color: Colors.m3onSecondaryContainer
            }
        }
    }

    RowLayout {
        id: hRow
        visible: !root.vertical
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        CircularProgress {
            id: hCirc
            Layout.alignment: Qt.AlignVCenter
            value: root.fraction
            color: root.low ? Colors.red : Colors.m3onSecondaryContainer

            Item {
                anchors.centerIn: parent
                width: hCirc.implicitSize
                height: hCirc.implicitSize
                MaterialIcon {
                    anchors.centerIn: parent
                    text: root.charging ? "bolt" : "battery_full"
                    fill: 1
                    pixelSize: Config.typography.normal
                    weight: Font.DemiBold
                    color: Colors.m3onSecondaryContainer
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: `${root.percentage}`
            font.family: Config.fontFamily
            font.pixelSize: Config.typography.small
            color: Colors.foreground
        }
    }
}
