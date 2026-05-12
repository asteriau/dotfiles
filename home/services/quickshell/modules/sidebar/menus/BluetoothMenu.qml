import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

WindowDialog {
    id: root
    backgroundHeight: 600
    show: UiState.sidebarMenu === "bluetooth"
    onDismiss: UiState.sidebarMenu = "none"

    onShowChanged: show ? BluetoothController.subscribe() : BluetoothController.unsubscribe()

    DialogTitle { text: "Bluetooth devices" }

    DialogSeparator { visible: !BluetoothController.discovering }
    DialogProgressBar {
        active: BluetoothController.discovering
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Appearance.layout.radiusLg
        Layout.rightMargin: -Appearance.layout.radiusLg
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Appearance.layout.radiusLg
        Layout.rightMargin: -Appearance.layout.radiusLg

        ListView {
            anchors.fill: parent
            visible: BluetoothController.devices.length > 0
            clip: true
            spacing: 0
            model: BluetoothController.devices
            ScrollBar.vertical: ScrollBar {}
            delegate: BluetoothDeviceRow {
                width: ListView.view.width
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 32
            visible: BluetoothController.devices.length === 0
            spacing: Appearance.layout.gapSm

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: BluetoothController.adapter ? "bluetooth_searching" : "bluetooth_disabled"
                color: Appearance.colors.m3onSurfaceInactive
                font.family: Appearance.typography.iconFamily
                font.pixelSize: 32
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: !BluetoothController.adapter
                    ? "No Bluetooth controller"
                    : (!BluetoothController.enabled ? "Bluetooth is off" : "No devices found")
                color: Appearance.colors.m3onSurface
                font.family: Config.typography.family
                font.pixelSize: Appearance.typography.smallie
                wrapMode: Text.Wrap
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                visible: !BluetoothController.adapter || !BluetoothController.enabled || BluetoothController.devices.length === 0
                text: !BluetoothController.adapter
                    ? "Plug in or enable a Bluetooth adapter"
                    : (!BluetoothController.enabled ? "Enable it from the toggle" : "Make sure the device is in pairing mode")
                color: Appearance.colors.m3onSurfaceInactive
                font.family: Config.typography.family
                font.pixelSize: Appearance.typography.smaller
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
