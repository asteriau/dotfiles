pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real memoryTotal: 1
    property real memoryFree: 0
    readonly property real memoryUsed: memoryTotal - memoryFree
    readonly property real memoryUsedPercentage: memoryUsed / memoryTotal

    property real swapTotal: 0
    property real swapFree: 0
    readonly property real swapUsed: swapTotal - swapFree
    readonly property real swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0

    property real cpuUsage: 0
    property var previousCpuStats: null

    readonly property string memUsedStr:  _kbToGb(memoryUsed)
    readonly property string memFreeStr:  _kbToGb(memoryFree)
    readonly property string memTotalStr: _kbToGb(memoryTotal)
    readonly property string swapUsedStr:  _kbToGb(swapUsed)
    readonly property string swapFreeStr:  _kbToGb(swapFree)
    readonly property string swapTotalStr: _kbToGb(swapTotal)

    function _kbToGb(kb: real): string {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            fileMeminfo.reload();
            fileStat.reload();

            const textMeminfo = fileMeminfo.text();
            root.memoryTotal = Number(textMeminfo.match(/MemTotal:\s*(\d+)/)?.[1] ?? 1);
            root.memoryFree  = Number(textMeminfo.match(/MemAvailable:\s*(\d+)/)?.[1] ?? 0);
            root.swapTotal   = Number(textMeminfo.match(/SwapTotal:\s*(\d+)/)?.[1] ?? 0);
            root.swapFree    = Number(textMeminfo.match(/SwapFree:\s*(\d+)/)?.[1] ?? 0);

            const textStat = fileStat.text();
            const cpuLine = textStat.match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
            if (cpuLine) {
                const stats = cpuLine.slice(1).map(Number);
                const total = stats.reduce((a, b) => a + b, 0);
                const idle  = stats[3];
                if (root.previousCpuStats) {
                    const dt = total - root.previousCpuStats.total;
                    const di = idle  - root.previousCpuStats.idle;
                    root.cpuUsage = dt > 0 ? (1 - di / dt) : 0;
                }
                root.previousCpuStats = { total, idle };
            }
        }
    }

    FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat;    path: "/proc/stat" }
}
