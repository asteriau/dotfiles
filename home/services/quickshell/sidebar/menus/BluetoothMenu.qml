import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.surfaces
import qs.services
import qs.utils

SidebarPopup {
    id: root
    title: "Bluetooth devices"
    active: UiState.sidebarMenu === "bluetooth"
    onDismissed: UiState.sidebarMenu = "none"

    Component.onCompleted: BluetoothState.subscribe()
    Component.onDestruction: BluetoothState.unsubscribe()

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            id: scanBar
            Layout.fillWidth: true
            implicitHeight: 3
            radius: 1.5
            color: BluetoothState.discovering ? "transparent" : Colors.outlineVariant
            opacity: BluetoothState.discovering ? 1 : 0.4
            clip: true

            Rectangle {
                visible: BluetoothState.discovering
                width: parent.width * 0.3
                height: parent.height
                radius: parent.radius
                color: Colors.colPrimary
                NumberAnimation on x {
                    running: scanBar.visible
                    loops: Animation.Infinite
                    from: -width
                    to: scanBar.width
                    duration: 1100
                }
            }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 0
            model: BluetoothState.devices
            ScrollBar.vertical: ScrollBar {}

            delegate: BluetoothDeviceRow {
                width: list.width
            }
        }

        Text {
            visible: BluetoothState.enabled && BluetoothState.devices.length === 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "No devices found"
            color: Colors.m3onSurfaceInactive
            font.family: "Inter"
            font.pixelSize: 12
        }

        Text {
            visible: !BluetoothState.enabled
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "Bluetooth is off — enable it from the toggle"
            color: Colors.m3onSurfaceInactive
            font.family: "Inter"
            font.pixelSize: 12
        }
    }
}
