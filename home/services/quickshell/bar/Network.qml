import QtQuick
import Quickshell
import Quickshell.Networking
import qs.components
import qs.utils

HoverTooltip {
    id: root

    // Pick the first adapter, or null
    property NetworkDevice adapter: Networking.devices?.values[0] ?? null

    // Find the active Wi-Fi network for this adapter
    readonly property WifiNetwork activeNetwork: adapter?.networks?.values.find(network => network.connected) ?? null

    // Check if any Ethernet is connected
    readonly property bool ethernetConnected: {
        return Networking.devices?.values.some(dev =>
            dev.type === "ethernet" && dev.connected
        ) ?? false;
    }

    // Only show Wi-Fi icon if Wi-Fi hardware is enabled AND Ethernet is not connected
    visible: !!Networking.devices?.values && adapter?.type === DeviceType.Wifi && !ethernetConnected

    readonly property string iconState: {
        if (!Networking.wifiHardwareEnabled)
            return "hardware-disabled";
        else if (!Networking.wifiEnabled)
            return "disabled";
        else if (adapter?.state == DeviceConnectionState.Connecting || adapter?.state == DeviceConnectionState.Disconnecting)
            return "acquiring";
        else if (adapter?.connected) {
            let strength = "good";

            if (activeNetwork?.signalStrength >= 0.66) {
                strength = "good";
            } else if (activeNetwork?.signalStrength >= 0.33) {
                strength = "ok";
            } else {
                strength = "weak";
            }
            return `signal-${strength}`;
        }
        return "offline";
    }

    readonly property string iconPath: Quickshell.iconPath(`network-wireless-${iconState}-symbolic`)

    text: {
        if (!Networking.wifiEnabled)
            return "WiFi disabled";
        else if (adapter?.state == DeviceConnectionState.Connecting)
            return `Connecting to ${activeNetwork.name}`;
        else if (adapter?.state == DeviceConnectionState.Disconnecting)
            return `Disconnecting from ${activeNetwork.name}`;
        else if (adapter?.connected)
            return activeNetwork?.name ?? null;

        return "Disconnected";
    }

    ShadowIcon {
        source: root.iconPath
        color: Colors.foreground
    }
}
