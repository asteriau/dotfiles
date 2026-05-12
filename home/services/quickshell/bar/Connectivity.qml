import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Networking
import qs.components.controls
import qs.components.effects
import qs.components.text
import qs.utils

HoverTooltip {
    id: root

    property bool vertical: Config.bar.vertical

    // ── WiFi ──────────────────────────────────────────────────────────────
    property NetworkDevice wifiAdapter: Networking.devices?.values?.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property WifiNetwork activeNetwork: wifiAdapter?.networks?.values.find(n => n.connected) ?? null
    readonly property bool ethernetConnected: Networking.devices?.values.some(d => d.type === "ethernet" && d.connected) ?? false

    readonly property string wifiState: {
        if (UiState.previewConnectivity)      return "signal-good";
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
    readonly property bool showWifi: UiState.previewConnectivity || (!!wifiAdapter && !ethernetConnected)
    readonly property real wifiValue: UiState.previewConnectivity ? 0.8
        : (wifiAdapter?.connected ? (activeNetwork?.signalStrength ?? 0) : 0)

    // ── Bluetooth ─────────────────────────────────────────────────────────
    property var btAdapter: Bluetooth.defaultAdapter
    readonly property var btConnected:  btAdapter?.devices.values.filter(d => d.state === BluetoothDeviceState.Connected)  ?? []
    readonly property var btConnecting: btAdapter?.devices.values.filter(d => d.state === BluetoothDeviceState.Connecting) ?? []
    readonly property bool showBt: !!btAdapter
    readonly property real btValue: {
        if (!btAdapter) return 0;
        if (btConnected.length)  return 1.0;
        if (btConnecting.length) return 0.5;
        if (btAdapter.state === BluetoothAdapterState.Enabled) return 0.25;
        return 0.1;
    }

    visible: showWifi || showBt

    text: {
        const lines = [];
        if (showWifi) {
            if (UiState.previewConnectivity)                                     lines.push("WiFi: Home Network");
            else if (!Networking.wifiEnabled)                                   lines.push("WiFi disabled");
            else if (wifiAdapter?.connected && activeNetwork)                   lines.push(`WiFi: ${activeNetwork.name}`);
            else if (wifiAdapter?.state === DeviceConnectionState.Connecting)   lines.push(`Connecting to ${activeNetwork?.name ?? "…"}`);
            else                                                                lines.push("WiFi disconnected");
        }
        if (showBt) {
            if (btAdapter.state === BluetoothAdapterState.Disabled)             lines.push("Bluetooth disabled");
            else if (btConnecting.length)                                       lines.push(`BT: connecting to ${btConnecting[0].name}`);
            else if (btConnected.length === 1) {
                const d = btConnected[0];
                lines.push(d.batteryAvailable ? `BT: ${d.name} ${Math.round(d.battery * 100)}%` : `BT: ${d.name}`);
            } else if (btConnected.length > 1)                                  lines.push(`BT: ${btConnected.length} devices`);
            else                                                                lines.push("Bluetooth disconnected");
        }
        return lines.join("\n");
    }

    implicitWidth:  chips.implicitWidth
    implicitHeight: chips.implicitHeight

    Grid {
        id: chips
        columns: root.vertical ? 1 : -1
        spacing: Config.layout.gapSm

        ClippedProgressBar {
            visible: root.showWifi
            vertical: root.vertical
            value: root.wifiValue
            valueBarWidth:  root.vertical ? 20 : 20
            valueBarHeight: root.vertical ? 20 : 18
            highlightColor: Appearance.colors.m3onSecondaryContainer

            Item {
                width: 20; height: root.vertical ? 20 : 18
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "wifi"
                    fill: 1
                    pixelSize: 12
                    weight: Font.DemiBold
                    color: "white"
                }
            }
        }

        ClippedProgressBar {
            visible: root.showBt
            vertical: root.vertical
            value: root.btValue
            valueBarWidth:  root.vertical ? 20 : 20
            valueBarHeight: root.vertical ? 20 : 18
            highlightColor: root.btConnected.length > 0 ? Appearance.colors.m3onSecondaryContainer
                : Qt.rgba(Appearance.colors.m3onSecondaryContainer.r, Appearance.colors.m3onSecondaryContainer.g, Appearance.colors.m3onSecondaryContainer.b, 0.7)

            Item {
                width: 20; height: root.vertical ? 20 : 18
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "bluetooth"
                    fill: 1
                    pixelSize: 12
                    weight: Font.DemiBold
                    color: "white"
                }
            }
        }
    }
}
