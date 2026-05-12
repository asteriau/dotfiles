pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    readonly property var devices: {
        if (!adapter) return [];
        const all = adapter.devices.values.slice();
        all.sort((a, b) => {
            const aRank = a.connected ? 0 : (a.paired ? 1 : 2);
            const bRank = b.connected ? 0 : (b.paired ? 1 : 2);
            if (aRank !== bRank) return aRank - bRank;
            return (a.name || "").localeCompare(b.name || "");
        });
        return all;
    }

    signal actionFailed(string deviceName, string message)

    property int subscribers: 0
    function subscribe(): void {
        root.subscribers += 1;
        root._syncDiscovery();
    }
    function unsubscribe(): void {
        root.subscribers = Math.max(0, root.subscribers - 1);
        root._syncDiscovery();
    }

    function _syncDiscovery(): void {
        if (!adapter) return;
        const want = root.subscribers > 0 && adapter.enabled;
        if (adapter.discovering !== want) adapter.discovering = want;
    }

    onEnabledChanged: _syncDiscovery()

    function setEnabled(on: bool): void {
        powerProc.command = ["bluetoothctl", "power", on ? "on" : "off"];
        powerProc.running = true;
    }

    function connect(dev): void {
        if (!dev) return;
        try { dev.connect(); } catch (e) { root.actionFailed(dev.name, String(e)); }
    }

    function disconnect(dev): void {
        if (!dev) return;
        try { dev.disconnect(); } catch (e) { root.actionFailed(dev.name, String(e)); }
    }

    function pair(dev): void {
        if (!dev) return;
        try { dev.pair(); } catch (e) { root.actionFailed(dev.name, String(e)); }
    }

    function forget(dev): void {
        if (!dev) return;
        try { dev.forget(); } catch (e) { root.actionFailed(dev.name, String(e)); }
    }

    Process { id: powerProc }
}
