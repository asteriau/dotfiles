pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int subscribers: 0
    function subscribe(): void { root.subscribers += 1 }
    function unsubscribe(): void { root.subscribers = Math.max(0, root.subscribers - 1) }

    property string distro: ""
    property string kernel: ""
    property string hostname: ""
    property string desktop: ""
    property string uptime: ""

    Process {
        running: true
        command: ["sh", "-c", ". /etc/os-release && echo \"$PRETTY_NAME\""]
        stdout: SplitParser { onRead: line => root.distro = line }
    }
    Process {
        running: true
        command: ["uname", "-r"]
        stdout: SplitParser { onRead: line => root.kernel = line }
    }
    Process {
        running: true
        command: ["sh", "-c", "hostnamectl hostname 2>/dev/null || uname -n"]
        stdout: SplitParser { onRead: line => root.hostname = line }
    }
    Process {
        running: true
        command: ["sh", "-c", "echo \"${XDG_CURRENT_DESKTOP:-unknown}\""]
        stdout: SplitParser { onRead: line => root.desktop = line }
    }

    function _refreshUptime(): void {
        uptimeFile.reload();
        const secs = Number((uptimeFile.text() || "").split(" ")[0] ?? 0);
        const days = Math.floor(secs / 86400);
        const hours = Math.floor((secs % 86400) / 3600);
        const minutes = Math.floor((secs % 3600) / 60);
        const parts = [];
        if (days > 0)
            parts.push(`${days} day${days === 1 ? "" : "s"}`);
        if (hours > 0)
            parts.push(`${hours} hour${hours === 1 ? "" : "s"}`);
        if (minutes > 0 || parts.length === 0)
            parts.push(`${minutes} minute${minutes === 1 ? "" : "s"}`);
        root.uptime = parts.join(", ");
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
    }

    Component.onCompleted: root._refreshUptime()

    Timer {
        interval: 60000
        repeat: true
        running: root.subscribers > 0
        triggeredOnStart: true
        onTriggered: root._refreshUptime()
    }
}
