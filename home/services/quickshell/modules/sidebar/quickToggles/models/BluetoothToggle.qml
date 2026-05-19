import QtQuick
import qs.services
import qs.modules.sidebar.quickToggles.models

QuickToggleModel {
    readonly property bool on: BluetoothController.enabled
    name: "Bluetooth"
    icon: on ? "bluetooth" : "bluetooth_disabled"
    statusText: on ? "On" : "Off"
    tooltipText: "Bluetooth | Right-click to configure"
    toggled: on
    hasMenu: true
    mainAction: () => BluetoothController.setEnabled(!BluetoothController.enabled)
}
