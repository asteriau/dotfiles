pragma Singleton
pragma ComponentBehavior: Bound

// Adapted from https://github.com/end-4/dots-hyprland (illogical-impulse).
// Simplified: brightnessctl only, no ddcutil, no anti-flashbang.

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property list<BrightnessMonitor> monitors: Quickshell.screens.map(screen => monitorComp.createObject(root, {
                screen
            }))

    // Primary (first) monitor brightness, exposed for consumers that don't
    // care about per-screen control.
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

    onMonitorsChanged: initializeMonitor(0)

    function initializeMonitor(i: int): void {
        if (i >= monitors.length)
            return;
        monitors[i].initialize();
    }

    Process {
        id: setProc
    }

    component BrightnessMonitor: QtObject {
        id: monitor

        required property var screen
        property int rawMaxBrightness: 100
        property real brightness: 0
        property bool ready: false

        function initialize(): void {
            monitor.ready = false;
            initProc.command = ["sh", "-c", "echo \"$(brightnessctl g) $(brightnessctl m)\""];
            initProc.running = true;
        }

        readonly property Process initProc: Process {
            stdout: SplitParser {
                onRead: data => {
                    const parts = data.trim().split(" ");
                    const current = parseInt(parts[0]);
                    const max = parseInt(parts[1]);
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

        function setBrightness(value: real): void {
            value = Math.max(0, Math.min(1, value));
            monitor.brightness = value;
            const valuePercentNumber = Math.floor(value * 100);
            const valuePercent = valuePercentNumber === 0 ? "1" : `${valuePercentNumber}%`;
            setProc.exec(["brightnessctl", "--class", "backlight", "s", valuePercent, "--quiet"]);
        }
    }

    Component {
        id: monitorComp

        BrightnessMonitor {}
    }
}
