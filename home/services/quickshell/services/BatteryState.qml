pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Thin wrapper over UPower's display device. Event-driven — no polling.
Singleton {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: device?.isLaptopBattery ?? false
    readonly property real level: device?.percentage ?? 0

    readonly property string status: {
        switch (device?.state) {
            case UPowerDeviceState.Charging:     return "Charging";
            case UPowerDeviceState.Discharging:  return "Discharging";
            case UPowerDeviceState.FullyCharged: return "Full";
            case UPowerDeviceState.NotCharging:  return "Not charging";
            default:                             return "Unknown";
        }
    }

    readonly property bool charging: status === "Charging" || status === "Full"
    readonly property bool low:      present && !charging && level <= 0.20
    readonly property bool critical: present && !charging && level <= 0.10
}
