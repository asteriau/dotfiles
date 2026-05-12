pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// nmcli-backed network state. Wraps Quickshell.Networking.wifiEnabled with
// scan/connect/disconnect plumbing the built-in API doesn't expose.
//
// Polling is ref-counted: scan loop runs only while subscribers > 0.
// Ethernet poll piggybacks on the same counter (was previously inline in
// QuickToggles.qml; consolidated here).
Singleton {
    id: root

    // --- live state ---
    readonly property bool wifiEnabled: Networking.wifiEnabled
    property bool ethernetConnected: false
    property bool scanning: false

    // [{ ssid, bssid, signal, freq, security, active, knownProfile }]
    property var wifiNetworks: []
    property var savedProfiles: []

    signal passwordRequired(string ssid)
    signal connected(string ssid)
    signal connectFailed(string ssid, string message)

    // --- ref-counted subscription ---
    property int subscribers: 0
    function subscribe(): void { root.subscribers += 1 }
    function unsubscribe(): void { root.subscribers = Math.max(0, root.subscribers - 1) }

    // --- public actions ---
    function setWifiEnabled(on: bool): void {
        wifiToggleProc.command = ["nmcli", "radio", "wifi", on ? "on" : "off"];
        wifiToggleProc.running = true;
    }

    function rescan(): void {
        if (scanProc.running) return;
        root.scanning = true;
        scanProc.running = true;
    }

    function connect(ssid: string, password: string): void {
        connectProc._ssid = ssid;
        if (password && password.length > 0)
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
        else
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        connectProc.running = true;
    }

    function disconnect(ssid: string): void {
        disconnectProc.command = ["nmcli", "connection", "down", "id", ssid];
        disconnectProc.running = true;
    }

    function forget(ssid: string): void {
        forgetProc.command = ["nmcli", "connection", "delete", "id", ssid];
        forgetProc.running = true;
    }

    // --- internal: polling ---
    Timer {
        interval: 8000
        running: root.subscribers > 0 && root.wifiEnabled
        repeat: true
        triggeredOnStart: true
        onTriggered: root.rescan()
    }

    Timer {
        interval: 3000
        running: root.subscribers > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: ethProc.running = true
    }

    Timer {
        interval: 10000
        running: root.subscribers > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: savedProfilesProc.running = true
    }

    // --- internal: processes ---
    Process { id: wifiToggleProc }

    Process {
        id: ethProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.ethernetConnected = text.split("\n").some(l => {
                    const [type, state] = l.split(":");
                    return type === "ethernet" && state === "connected";
                });
            }
        }
    }

    Process {
        id: savedProfilesProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                const names = [];
                text.split("\n").forEach(l => {
                    if (!l) return;
                    const [name, type] = root._splitNmcli(l);
                    if (type === "802-11-wireless" && name) names.push(name);
                });
                root.savedProfiles = names;
            }
        }
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SIGNAL,FREQ,SSID,BSSID,SECURITY", "device", "wifi", "list", "--rescan", "yes"]
        stdout: StdioCollector {
            onStreamFinished: {
                const seen = {};
                const list = [];
                text.split("\n").forEach(l => {
                    if (!l) return;
                    const parts = root._splitNmcli(l);
                    if (parts.length < 6) return;
                    const ssid = parts[3];
                    if (!ssid) return;
                    const entry = {
                        active:   parts[0] === "yes",
                        signal:   parseInt(parts[1]) || 0,
                        freq:     parseInt(parts[2]) || 0,
                        ssid:     ssid,
                        bssid:    parts[4],
                        security: parts[5],
                    };
                    entry.knownProfile = root.savedProfiles.indexOf(ssid) !== -1;
                    const prior = seen[ssid];
                    if (!prior || entry.signal > prior.signal || entry.active) {
                        seen[ssid] = entry;
                    }
                });
                Object.values(seen).forEach(e => list.push(e));
                list.sort((a, b) => {
                    if (a.active !== b.active) return a.active ? -1 : 1;
                    return b.signal - a.signal;
                });
                root.wifiNetworks = list;
                root.scanning = false;
            }
        }
        onRunningChanged: {
            if (!running) root.scanning = false;
        }
    }

    Process {
        id: connectProc
        property string _ssid: ""
        stdout: StdioCollector { id: connectStdout }
        stderr: StdioCollector { id: connectStderr }
        onExited: (code, status) => {
            const ssid = connectProc._ssid;
            const errText = connectStderr.text || "";
            const outText = connectStdout.text || "";
            if (code === 0) {
                root.connected(ssid);
                root.rescan();
            } else if (errText.match(/Secrets were required|password|no secret|Authentication/i)) {
                root.passwordRequired(ssid);
            } else {
                const msg = (errText || outText).trim() || ("nmcli exited " + code);
                root.connectFailed(ssid, msg);
            }
            connectProc._ssid = "";
        }
    }

    Process { id: disconnectProc; onExited: (code, status) => root.rescan() }
    Process { id: forgetProc;     onExited: (code, status) => root.rescan() }

    // nmcli -t escapes literal colons as `\:`; split on unescaped colons then unescape.
    function _splitNmcli(line: string): var {
        const out = [];
        let cur = "";
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            if (c === "\\" && i + 1 < line.length) {
                cur += line[i + 1];
                i++;
            } else if (c === ":") {
                out.push(cur);
                cur = "";
            } else {
                cur += c;
            }
        }
        out.push(cur);
        return out;
    }
}
