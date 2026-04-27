pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

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

    Process {
        id: uptimeProc
        running: true
        command: ["sh", "-c", "uptime -p"]
        stdout: SplitParser {
            onRead: line => root.uptime = line.replace(/^up\s+/, "")
        }
    }

    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: uptimeProc.running = true
    }
}
