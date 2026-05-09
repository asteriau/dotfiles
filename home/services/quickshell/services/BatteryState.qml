pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string batteryPath: ""
    property bool present: false
    property real level: 0           // 0..1
    property string status: "Unknown" // Charging / Discharging / Full / Not charging / Unknown
    readonly property bool charging: status === "Charging" || status === "Full"
    readonly property bool low: present && !charging && level <= 0.20
    readonly property bool critical: present && !charging && level <= 0.10

    Process {
        id: discover
        running: true
        command: ["sh", "-c",
            "for d in /sys/class/power_supply/BAT*; do " +
            "  [ -d \"$d\" ] && [ \"$(cat \"$d/type\" 2>/dev/null)\" = Battery ] && echo \"$d\" && exit 0; " +
            "done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim();
                root.batteryPath = t;
                root.present = t.length > 0;
            }
        }
    }

    FileView {
        id: capFile
        path: root.batteryPath ? root.batteryPath + "/capacity" : ""
        watchChanges: false
        blockLoading: false
        onLoaded: {
            const n = parseInt(text().trim());
            if (!isNaN(n)) root.level = Math.max(0, Math.min(100, n)) / 100;
        }
    }
    FileView {
        id: statFile
        path: root.batteryPath ? root.batteryPath + "/status" : ""
        watchChanges: false
        blockLoading: false
        onLoaded: root.status = text().trim() || "Unknown"
    }

    Timer {
        interval: 5000
        running: root.present
        repeat: true
        triggeredOnStart: true
        onTriggered: { capFile.reload(); statFile.reload(); }
    }
}
