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

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Config.layout.radiusLg
        Layout.rightMargin: -Config.layout.radiusLg
        clip: true
        spacing: 0
        model: BluetoothState.devices
        ScrollBar.vertical: ScrollBar {}
        delegate: BluetoothDeviceRow {
            width: ListView.view.width
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
