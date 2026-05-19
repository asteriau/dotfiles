pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common.functions

Singleton {
    id: root

    property int subscribers: 0
    function subscribe(): void {
        root.subscribers += 1;
    }
    function unsubscribe(): void {
        root.subscribers = Math.max(0, root.subscribers - 1);
    }

    property string distro: ""
    property string distroId: "unknown"
    property string distroIcon: "linux-symbolic.svg"
    property string kernel: ""
    property string hostname: ""
    property string desktop: ""
    property string uptime: ""
    property real uptimeSeconds: 0
    // Compact form ("3h, 12m") for the sidebar header; `uptime` stays verbose.
    readonly property string uptimeShort: DateUtils.formatDuration(uptimeSeconds)

    function _resolveDistroIcon(): void {
        let icon;
        switch (root.distroId) {
            case "artix":
            case "arch":
            icon = "arch-symbolic.svg";
            break;
            case "endeavouros":
            icon = "endeavouros-symbolic.svg";
            break;
            case "cachyos":
            icon = "cachyos-symbolic.svg";
            break;
            case "nixos":
            icon = "nixos-symbolic.svg";
            break;
            case "fedora":
            icon = "fedora-symbolic.svg";
            break;
            case "linuxmint":
            case "ubuntu":
            case "zorin":
            case "popos":
            icon = "ubuntu-symbolic.svg";
            break;
            case "debian":
            case "raspbian":
            case "kali":
            icon = "debian-symbolic.svg";
            break;
            case "funtoo":
            case "gentoo":
            icon = "gentoo-symbolic.svg";
            break;
            default:
            icon = "linux-symbolic.svg";
            break;
        }
        if (root.distro.toLowerCase().includes("nyarch"))
        icon = "nyarch-symbolic.svg";
        root.distroIcon = icon;
    }

    onDistroIdChanged: root._resolveDistroIcon()
    onDistroChanged: root._resolveDistroIcon()

    Process {
        running: true
        command: ["sh", "-c", ". /etc/os-release && echo \"$PRETTY_NAME\""]
        stdout: SplitParser {
            onRead: line => root.distro = line
        }
    }
    Process {
        running: true
        command: ["sh", "-c", ". /etc/os-release && echo \"$ID\""]
        stdout: SplitParser {
            onRead: line => root.distroId = line.trim()
        }
    }
    Process {
        running: true
        command: ["uname", "-r"]
        stdout: SplitParser {
            onRead: line => root.kernel = line
        }
    }
    Process {
        running: true
        command: ["sh", "-c", "hostnamectl hostname 2>/dev/null || uname -n"]
        stdout: SplitParser {
            onRead: line => root.hostname = line
        }
    }
    Process {
        running: true
        command: ["sh", "-c", "echo \"${XDG_CURRENT_DESKTOP:-unknown}\""]
        stdout: SplitParser {
            onRead: line => root.desktop = line
        }
    }

    function _refreshUptime(): void {
        uptimeFile.reload();
        const secs = Number((uptimeFile.text() || "").split(" ")[0] ?? 0);
        root.uptimeSeconds = secs;
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
