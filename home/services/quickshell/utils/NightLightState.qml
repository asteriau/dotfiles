pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int minTemp: 2500
    readonly property int maxTemp: 6500

    property int temperature: maxTemp
    readonly property bool active: temperature < maxTemp

    function tempToSlider(k: int): real {
        return Math.max(0, Math.min(1, (maxTemp - k) / (maxTemp - minTemp)));
    }

    function sliderToTemp(v: real): int {
        return Math.round(maxTemp - Math.max(0, Math.min(1, v)) * (maxTemp - minTemp));
    }

    function ensureDaemon(): void {
        Quickshell.execDetached(["bash", "-c", "pidof hyprsunset || hyprsunset"]);
    }

    function setTemperature(k: int): void {
        const clamped = Math.max(minTemp, Math.min(maxTemp, k));
        temperature = clamped;
        if (clamped >= maxTemp - 50) {
            Quickshell.execDetached(["hyprctl", "hyprsunset", "identity"]);
        } else {
            ensureDaemon();
            Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(clamped)]);
        }
    }

    Process {
        id: fetchProc
        running: true
        command: ["hyprctl", "hyprsunset", "temperature"]
        stdout: StdioCollector {
            id: fetchCollector
            onStreamFinished: {
                const out = fetchCollector.text.trim();
                if (out.length === 0 || out.startsWith("Couldn't")) {
                    root.temperature = root.maxTemp;
                    return;
                }
                const k = parseInt(out);
                if (!isNaN(k))
                    root.temperature = Math.max(root.minTemp, Math.min(root.maxTemp, k));
            }
        }
    }
}
