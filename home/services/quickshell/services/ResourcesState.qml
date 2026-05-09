pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Ref-counted subscribers — Timer ticks only while at least one consumer
    // is mounted. Consumers call subscribe()/unsubscribe() in
    // Component.onCompleted / onDestruction.
    property int subscribers: 0
    function subscribe(): void { root.subscribers += 1 }
    function unsubscribe(): void { root.subscribers = Math.max(0, root.subscribers - 1) }

    property real memoryTotal: 1
    property real memoryFree: 0
    readonly property real memoryUsed: memoryTotal - memoryFree
    readonly property real memoryUsedPercentage: memoryUsed / memoryTotal

    property real swapTotal: 0
    property real swapFree: 0
    readonly property real swapUsed: swapTotal - swapFree
    readonly property real swapUsedPercentage: swapTotal > 0 ? (swapUsed / swapTotal) : 0

    property real cpuUsage: 0
    property list<real> cpuCoreUsages: []
    property var previousCpuStats: null
    property var previousCoreStats: []

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
        running: root.subscribers > 0
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
            const lines = textStat.split("\n");
            
            // Total CPU
            const cpuLine = lines[0].match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
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

            // Per-core CPU
            let coreUsages = [];
            let coreStats = [];
            for (let i = 1; i < lines.length; i++) {
                const match = lines[i].match(/^cpu(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
                if (!match) continue;
                
                const coreIdx = parseInt(match[1]);
                const stats = match.slice(2).map(Number);
                const total = stats.reduce((a, b) => a + b, 0);
                const idle  = stats[3];
                
                let usage = 0;
                if (root.previousCoreStats[coreIdx]) {
                    const dt = total - root.previousCoreStats[coreIdx].total;
                    const di = idle  - root.previousCoreStats[coreIdx].idle;
                    usage = dt > 0 ? (1 - di / dt) : 0;
                }
                coreUsages.push(usage);
                coreStats[coreIdx] = { total, idle };
            }
            root.cpuCoreUsages = coreUsages;
            root.previousCoreStats = coreStats;

            let coreWeights = [];
            for (let i = 0; i < coreUsages.length; i++) {
                coreWeights.push(1.0);
            }
            root.cpuCoreWeights = coreWeights;
        }
    }

    property list<real> cpuCoreWeights: []

    FileView { id: fileMeminfo; path: "/proc/meminfo" }
    FileView { id: fileStat;    path: "/proc/stat" }
}
