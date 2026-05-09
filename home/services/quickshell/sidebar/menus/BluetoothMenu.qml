import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.controls
import qs.components.surfaces
import qs.services
import qs.utils

WindowDialog {
    id: root
    backgroundHeight: 600
    show: UiState.sidebarMenu === "bluetooth"
    onDismiss: UiState.sidebarMenu = "none"

    onShowChanged: show ? BluetoothState.subscribe() : BluetoothState.unsubscribe()

    DialogTitle { text: "Bluetooth devices" }

    DialogSeparator { visible: !BluetoothState.discovering }
    DialogProgressBar {
        active: BluetoothState.discovering
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Config.layout.radiusLg
        Layout.rightMargin: -Config.layout.radiusLg
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Config.layout.radiusLg
        Layout.rightMargin: -Config.layout.radiusLg

        ListView {
            anchors.fill: parent
            visible: BluetoothState.devices.length > 0
            clip: true
            spacing: 0
            model: BluetoothState.devices
            ScrollBar.vertical: ScrollBar {}
            delegate: BluetoothDeviceRow {
                width: ListView.view.width
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 32
            visible: BluetoothState.devices.length === 0
            spacing: Config.layout.gapSm

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: BluetoothState.adapter ? "bluetooth_searching" : "bluetooth_disabled"
                color: Colors.m3onSurfaceInactive
                font.family: Config.typography.iconFamily
                font.pixelSize: 32
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: !BluetoothState.adapter
                    ? "No Bluetooth controller"
                    : (!BluetoothState.enabled ? "Bluetooth is off" : "No devices found")
                color: Colors.m3onSurface
                font.family: Config.typography.family
                font.pixelSize: Config.typography.smallie
                wrapMode: Text.Wrap
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: !BluetoothState.adapter || !BluetoothState.enabled || BluetoothState.devices.length === 0
                text: !BluetoothState.adapter
                    ? "Plug in or enable a Bluetooth adapter"
                    : (!BluetoothState.enabled ? "Enable it from the toggle" : "Make sure the device is in pairing mode")
                color: Colors.m3onSurfaceInactive
                font.family: Config.typography.family
                font.pixelSize: Config.typography.smaller
                wrapMode: Text.Wrap
            }
        }
    }

    DialogSeparator {}

    DialogButtonRow {
        Item { Layout.fillWidth: true }

        DialogButton {
            text: "Done"
            onClicked: root.dismiss()
        }
    }
}
