import QtQuick
import Quickshell.Services.UPower
import qs.components.effects
import qs.utils

HoverTooltip {
    id: root

    property bool vertical: true

    readonly property var  battery: UPower.displayDevice
    readonly property int  percentage: Math.round(battery.percentage * 100)
    readonly property bool charging: battery.state === UPowerDeviceState.Charging
        || battery.state === UPowerDeviceState.FullyCharged

    visible: battery.isLaptopBattery

    text: `Battery ${percentage}%${charging ? " (charging)" : ""}`

    implicitWidth:  vertical ? 20 : hRow.implicitWidth
    implicitHeight: vertical ? 62 : hRow.implicitHeight

    // Vertical variant: stacked terminal + filled body.
    Column {
        visible: root.vertical
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
                            duration: M3Easing.durationMedium2
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }

    // Horizontal variant: icon + percentage text.
    Row {
        id: hRow
        visible: !root.vertical
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Item {
            implicitWidth: 28
            implicitHeight: 12
            anchors.verticalCenter: parent.verticalCenter

            // Terminal cap on the right.
            Rectangle {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                width: 3
                height: 6
                radius: 1
                color: Colors.comment
            }

            // Outer body.
            Rectangle {
                width: 24
                height: 12
                radius: 3
                color: "transparent"
                border.color: Colors.comment
                border.width: 1
                clip: true

                // Fill.
                Rectangle {
                    anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 2 }
                    width: Math.max(0, (parent.width - 4) * Math.min(1, root.battery.percentage))
                    radius: 2
                    color: Qt.rgba(Colors.mpris.r, Colors.mpris.g, Colors.mpris.b, 0.85)
                    Behavior on width {
                        NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutQuad }
                    }
                }
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: `${root.percentage}%`
            font.pixelSize: 11
            font.family: Config.typography.family
            color: Colors.comment
        }
    }
}
