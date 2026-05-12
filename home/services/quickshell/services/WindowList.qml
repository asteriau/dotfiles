pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root
    property var windowList: []

    function biggestWindowForWorkspace(workspaceId) {
        const wins = root.windowList.filter(w => w.workspace.id == workspaceId);
        return wins.reduce((max, win) => {
            const maxA = (max?.size?.[0] ?? 0) * (max?.size?.[1] ?? 0);
            const winA = (win?.size?.[0] ?? 0) * (win?.size?.[1] ?? 0);
            return winA > maxA ? win : max;
        }, null);
    }

    Component.onCompleted: getClients.running = true

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!["openlayer", "closelayer", "screencast"].includes(event.name))
                getClients.running = true;
        }
    }

    Process {
        id: getClients
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.windowList = JSON.parse(text)
        }
    }
}
