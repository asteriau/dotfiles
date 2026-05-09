import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.controls
import qs.components.surfaces
import qs.services
import qs.utils

SidebarPopup {
    id: root
    active: UiState.sidebarMenu === "bluetooth"
    onDismissed: UiState.sidebarMenu = "none"

    Component.onCompleted: BluetoothState.subscribe()
    Component.onDestruction: BluetoothState.unsubscribe()

    ColumnLayout {
        anchors.fill: parent
        spacing: Config.layout.gapSm

        MenuHeader {
            title: "Bluetooth devices"
            onBack: UiState.sidebarMenu = "none"
        }

        MenuIndeterminateBar {
            Layout.fillWidth: true
            active: BluetoothState.discovering
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: BluetoothState.enabled && BluetoothState.devices.length > 0
            clip: true
            spacing: Config.layout.gapSm
            model: BluetoothState.devices
            ScrollBar.vertical: ScrollBar {}

            delegate: BluetoothDeviceRow {
                width: list.width
            }
        }

        Item {
            visible: BluetoothState.enabled && BluetoothState.devices.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            MenuEmptyState {
                anchors.centerIn: parent
                width: parent.width
                iconName: "bluetooth_disabled"
                title: "No devices found"
                detail: "Make sure the device is in pairing mode"
            }
        }

        Item {
            visible: !BluetoothState.enabled
            Layout.fillWidth: true
            Layout.fillHeight: true

            MenuEmptyState {
                anchors.centerIn: parent
                width: parent.width
                iconName: "bluetooth_disabled"
                title: "Bluetooth is off"
                detail: "Enable it from the toggle"
            }
        }
    }
}
