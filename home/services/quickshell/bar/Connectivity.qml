import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.components.effects
import qs.components.text
import qs.utils

// Stacked connectivity chip: WiFi as base, Bluetooth as a small badge anchored
// bottom-right. One chip replaces the previous Network + Bluetooth widgets.
HoverTooltip {
    id: root

    // ── WiFi ──────────────────────────────────────────────────────────────
    property NetworkDevice wifiAdapter: Networking.devices?.values?.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property WifiNetwork activeNetwork: wifiAdapter?.networks?.values.find(n => n.connected) ?? null
    readonly property bool ethernetConnected: {
        return Networking.devices?.values.some(d => d.type === "ethernet" && d.connected) ?? false;
    }

    readonly property string wifiState: {
        if (!Networking.wifiHardwareEnabled) return "hardware-disabled";
        if (!Networking.wifiEnabled)         return "disabled";
        if (wifiAdapter?.state === DeviceConnectionState.Connecting
         || wifiAdapter?.state === DeviceConnectionState.Disconnecting) return "acquiring";
        if (wifiAdapter?.connected) {
            const s = activeNetwork?.signalStrength ?? 0;
            if (s >= 0.66) return "signal-good";
            if (s >= 0.33) return "signal-ok";
            return "signal-weak";
        }
        return "offline";
    }
    readonly property bool showWifi: !!wifiAdapter && !ethernetConnected

    // ── Bluetooth ─────────────────────────────────────────────────────────
    property var btAdapter: Bluetooth.defaultAdapter
    readonly property var btConnected:  btAdapter?.devices.values.filter(d => d.state === BluetoothDeviceState.Connected) ?? []
    readonly property var btConnecting: btAdapter?.devices.values.filter(d => d.state === BluetoothDeviceState.Connecting) ?? []
    readonly property string btState: {
        if (btAdapter?.state === BluetoothAdapterState.Blocked)  return "hardware-disabled";
        if (btAdapter?.state === BluetoothAdapterState.Disabled) return "disabled";
        if (btConnecting.length) return "acquiring";
        if (btConnected.length)  return "active";
        if (btAdapter?.state === BluetoothAdapterState.Enabled) return "disconnected";
        return "acquiring";
    }
    // Only badge when interesting (active/connecting) and adapter present.
    readonly property bool showBtBadge: !!btAdapter && (btConnected.length > 0 || btConnecting.length > 0)

    visible: showWifi || !!btAdapter

    text: {
        const lines = [];
        if (showWifi) {
            if (!Networking.wifiEnabled) lines.push("WiFi disabled");
            else if (wifiAdapter?.connected && activeNetwork) lines.push(`WiFi: ${activeNetwork.name}`);
            else if (wifiAdapter?.state === DeviceConnectionState.Connecting) lines.push(`Connecting to ${activeNetwork?.name ?? "…"}`);
            else lines.push("WiFi disconnected");
        }
        if (btAdapter) {
            if (btAdapter.state === BluetoothAdapterState.Disabled) lines.push("Bluetooth disabled");
            else if (btConnecting.length) lines.push(`BT: connecting to ${btConnecting[0].name}`);
            else if (btConnected.length === 1) {
                const d = btConnected[0];
                lines.push(d.batteryAvailable ? `BT: ${d.name} ${Math.round(d.battery * 100)}%` : `BT: ${d.name}`);
            } else if (btConnected.length > 1) lines.push(`BT: ${btConnected.length} devices`);
            else lines.push("Bluetooth disconnected");
        }
        return lines.join("\n");
    }

    Item {
        implicitWidth:  Config.iconSize
        implicitHeight: Config.iconSize

        ShadowIcon {
            anchors.centerIn: parent
            visible: root.showWifi
            source: Quickshell.iconPath(`network-wireless-${root.wifiState}-symbolic`)
            color: Colors.foreground
        }

        // Fallback when WiFi hidden (ethernet/no wifi adapter): show BT alone.
        ShadowIcon {
            anchors.centerIn: parent
            visible: !root.showWifi && !!root.btAdapter
            source: Quickshell.iconPath(`bluetooth-${root.btState}-symbolic`)
            color: Colors.foreground
        }

        // Bluetooth badge when WiFi is the base.
        Rectangle {
            visible: root.showWifi && root.showBtBadge
            width:  9
            height: 9
            radius: width / 2
            color: Colors.surfaceContainerLow
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            Rectangle {
                anchors.centerIn: parent
                width:  7
                height: 7
                radius: width / 2
                color: root.btState === "acquiring" ? Colors.accentHover : Colors.accent
            }
        }
    }
}
