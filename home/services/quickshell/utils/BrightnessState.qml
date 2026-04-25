pragma Singleton
pragma ComponentBehavior: Bound

// Adapted from https://github.com/end-4/dots-hyprland (illogical-impulse)
// and https://github.com/caelestia-dots/shell.
// Supports brightnessctl (laptop backlight) + ddcutil (external DDC/CI).

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property var ddcMonitors: []

    readonly property list<BrightnessMonitor> monitors: Quickshell.screens.map(screen => monitorComp.createObject(root, {
                screen
            }))

    readonly property real brightness: monitors.length > 0 ? monitors[0].brightness : 0
    readonly property bool ready: monitors.length > 0 && monitors[0].ready

    function getMonitorForScreen(screen): var {
        return monitors.find(m => m.screen === screen);
    }

    function setBrightness(value: real): void {
        if (monitors.length > 0)
            monitors[0].setBrightness(value);
    }

    function increaseBrightness(): void {
        if (monitors.length > 0)
            monitors[0].setBrightness(monitors[0].brightness + 0.05);
    }

    function decreaseBrightness(): void {
        if (monitors.length > 0)
            monitors[0].setBrightness(monitors[0].brightness - 0.05);
    }

    reloadableId: "brightness"

    onMonitorsChanged: {
        ddcMonitors = [];
        ddcProc.running = true;
    }

    function initializeMonitor(i: int): void {
        if (i >= monitors.length)
            return;
        monitors[i].initialize();
    }

    Process {
        id: ddcProc
        command: ["ddcutil", "detect", "--brief"]
        stdout: SplitParser {
            splitMarker: "\n\n"
            onRead: data => {
                if (data.startsWith("Display ")) {
                    const lines = data.split("\n").map(l => l.trim());
                    const drmLine = lines.find(l => l.startsWith("DRM_connector:") || l.startsWith("DRM connector:"));
                    const busLine = lines.find(l => l.startsWith("I2C bus:"));
                    if (!drmLine || !busLine)
                        return;
                    const name = drmLine.split(":")[1].trim().split("-").slice(1).join("-");
                    const busNum = busLine.split("/dev/i2c-")[1];
                    root.ddcMonitors.push({ name, busNum });
                }
            }
        }
        onExited: root.initializeMonitor(0)
    }

    component BrightnessMonitor: QtObject {
        id: monitor

        required property var screen
        property bool isDdc: false
        property string busNum: ""
        property int rawMaxBrightness: 100
        property real brightness: 0
        property bool ready: false

        function initialize(): void {
            monitor.ready = false;
            const match = root.ddcMonitors.find(m => m.name === screen.name && !root.monitors.slice(0, root.monitors.indexOf(monitor)).some(mon => mon.busNum === m.busNum));
            isDdc = !!match;
            busNum = match?.busNum ?? "";
            initProc.command = isDdc
                ? ["ddcutil", "-b", busNum, "getvcp", "10", "--brief"]
                : ["sh", "-c", "echo \"a b c $(brightnessctl g) $(brightnessctl m)\""];
            initProc.running = true;
        }

        readonly property Process initProc: Process {
            stdout: SplitParser {
                onRead: data => {
                    const parts = data.trim().split(/\s+/);
                    // ddcutil --brief: "VCP 10 C <current> <max>"; brightnessctl: "a b c <current> <max>"
                    const current = parseInt(parts[3]);
                    const max = parseInt(parts[4]);
                    if (!isNaN(max) && max > 0) {
                        monitor.rawMaxBrightness = max;
                        monitor.brightness = (!isNaN(current) ? current : 0) / max;
                        monitor.ready = true;
                    }
                }
            }
            onExited: (exitCode, exitStatus) => {
                root.initializeMonitor(root.monitors.indexOf(monitor) + 1);
            }
        }

        // DDC over I2C is slow; debounce writes during slider drag.
        readonly property Process setProc: Process {}

        property var setTimer: Timer {
            interval: monitor.isDdc ? 300 : 0
            onTriggered: monitor.syncBrightness()
        }

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));
            monitor.brightness = value;
            monitor.setTimer.restart();
        }

        function syncBrightness(): void {
            const value = Math.max(0, Math.min(1, monitor.brightness));
            if (monitor.isDdc) {
                const raw = Math.max(Math.floor(value * monitor.rawMaxBrightness), 1);
                monitor.setProc.exec(["ddcutil", "-b", monitor.busNum, "setvcp", "10", String(raw)]);
            } else {
                const pct = Math.floor(value * 100);
                const arg = pct === 0 ? "1" : `${pct}%`;
                monitor.setProc.exec(["brightnessctl", "--class", "backlight", "s", arg, "--quiet"]);
            }
        }
    }

    Component {
        id: monitorComp
        BrightnessMonitor {}
    }
}
