pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string uptimeText: ""

    function format(seconds) {
        const s = Math.floor(seconds);
        const d = Math.floor(s / 86400);
        const h = Math.floor((s % 86400) / 3600);
        const m = Math.floor((s % 3600) / 60);
        if (d > 0)
            return `up ${d}d ${h}h`;
        if (h > 0)
            return `up ${h}h ${m}m`;
        return `up ${m}m`;
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        blockLoading: true
        onLoaded: {
            const parts = text().trim().split(" ");
            root.uptimeText = root.format(Number(parts[0]));
        }
    }

    Component.onCompleted: uptimeFile.reload()

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: uptimeFile.reload()
    }
}
