import QtQuick
import Quickshell.Services.UPower
import qs.components
import qs.utils

HoverTooltip {
    id: root

    readonly property var battery: UPower.displayDevice
    readonly property int percentage: Math.round(battery.percentage * 100)
    readonly property bool charging: battery.state == UPowerDeviceState.Charging || battery.state == UPowerDeviceState.FullyCharged

    visible: battery.isLaptopBattery

    text: `Battery ${percentage}%${charging ? " (charging)" : ""}`

    implicitWidth: 20
    implicitHeight: 62

    Column {
        anchors.centerIn: parent
        spacing: 4

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 10
            height: 4
            radius: 2
            color: Colors.comment
        }

        Rectangle {
            width: 14
            height: 48
            radius: 8
            color: "transparent"
            border.color: Colors.comment
            border.width: 1

            Item {
                anchors.fill: parent
                anchors.margins: 3
                clip: true

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * Math.max(0, Math.min(1, root.battery.percentage))
                    radius: 4
                    color: Qt.rgba(Colors.mpris.r, Colors.mpris.g, Colors.mpris.b, 0.25)

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: Colors.mpris
                        opacity: 0.85
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }
}
