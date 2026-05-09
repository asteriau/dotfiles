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
        running: root.subscribers > 0
        onTriggered: uptimeProc.running = true
    }
}
