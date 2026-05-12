import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

// Watches BatteryState.charging transitions and exposes a peek window.
// Island.qml reads `active` (peek mode visible) and `peeking` (force-expand).
Item {
    id: root

    property bool active: false
    property bool peeking: false

    property bool _lastCharging: false
    property bool _seeded: false

    Timer {
        id: peekTimer
        interval: Appearance.island.peekDurationMs
        onTriggered: root.peeking = false
    }
    Timer {
        id: hideTimer
        interval: Appearance.island.batteryPeekMs
        onTriggered: root.active = false
    }

    Connections {
        target: BatteryState
        function onChargingChanged() {
            if (!root._seeded) {
                root._lastCharging = BatteryState.charging;
                root._seeded = true;
                return;
            }
            if (BatteryState.charging !== root._lastCharging) {
                root._lastCharging = BatteryState.charging;
                root.active = true;
                root.peeking = true;
                peekTimer.restart();
                hideTimer.restart();
            }
        }
    }
}
