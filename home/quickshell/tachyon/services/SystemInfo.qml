pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

/**
 * Provides some system info: distro, username.
 */
Singleton {
    id: root
    property string distroName: "Unknown"
    property string distroId: "unknown"
    property string distroIcon: "linux-symbolic"
    property string username: "user"
    property string homeUrl: ""
    property string documentationUrl: ""
    property string supportUrl: ""
    property string bugReportUrl: ""
    property string privacyPolicyUrl: ""
    property string logo: ""
    property string desktopEnvironment: ""
    property string windowingSystem: ""
    property string kernel: ""
    property string hostname: ""
    property string uptime: ""

    property int subscribers: 0
    function subscribe(): void { root.subscribers += 1 }
    function unsubscribe(): void { root.subscribers = Math.max(0, root.subscribers - 1) }

    Process {
        running: true
        command: ["sh", "-c", "uname -r; uname -n"]
        stdout: StdioCollector {
            id: unameCollector
            onStreamFinished: {
                const [k, h] = unameCollector.text.trim().split("\n")
                root.kernel = k ?? ""
                root.hostname = h ?? ""
            }
        }
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
    }

    Timer {
        interval: 60000
        repeat: true
        running: root.subscribers > 0
        triggeredOnStart: true
        onTriggered: {
            uptimeFile.reload()
            const secs = Number((uptimeFile.text() || "0").split(" ")[0])
            const d = Math.floor(secs / 86400), h = Math.floor(secs % 86400 / 3600), m = Math.floor(secs % 3600 / 60)
            root.uptime = [d && `${d}d`, h && `${h}h`, `${m}m`].filter(Boolean).join(" ")
        }
    }

    Timer {
        triggeredOnStart: true
        interval: 1
        running: true
        repeat: false
        onTriggered: {
            getUsername.running = true
            fileOsRelease.reload()
            const textOsRelease = fileOsRelease.text()

            // Extract the friendly name (PRETTY_NAME field, fallback to NAME)
            const prettyNameMatch = textOsRelease.match(/^PRETTY_NAME=['"](.+?)['"]/m)
            const nameMatch = textOsRelease.match(/^NAME=['"](.+?)['"]/m)
            distroName = prettyNameMatch ? prettyNameMatch[1] : (nameMatch ? nameMatch[1].replace(/Linux/i, "").trim() : "Unknown")

            // Extract the ID
            const idMatch = textOsRelease.match(/^ID=['"]?(.+?)['"]?$/m)
            distroId = idMatch ? idMatch[1] : "unknown"

            // Extract additional URLs and logo
            const homeUrlMatch = textOsRelease.match(/^HOME_URL=['"](.+?)['"]/m)
            homeUrl = homeUrlMatch ? homeUrlMatch[1] : ""
            const documentationUrlMatch = textOsRelease.match(/^DOCUMENTATION_URL=['"](.+?)['"]/m)
            documentationUrl = documentationUrlMatch ? documentationUrlMatch[1] : ""
            const supportUrlMatch = textOsRelease.match(/^SUPPORT_URL=['"](.+?)['"]/m)
            supportUrl = supportUrlMatch ? supportUrlMatch[1] : ""
            const bugReportUrlMatch = textOsRelease.match(/^BUG_REPORT_URL=['"](.+?)['"]/m)
            bugReportUrl = bugReportUrlMatch ? bugReportUrlMatch[1] : ""
            const privacyPolicyUrlMatch = textOsRelease.match(/^PRIVACY_POLICY_URL=['"](.+?)['"]/m)
            privacyPolicyUrl = privacyPolicyUrlMatch ? privacyPolicyUrlMatch[1] : ""
            const logoFieldMatch = textOsRelease.match(/^LOGO=['"]?(.+?)['"]?$/m)
            logo = logoFieldMatch ? logoFieldMatch[1] : ""

            // Update the distroIcon property based on distroId
            switch (distroId) {
                case "artix":
                case "arch": distroIcon = "arch-symbolic"; break;
                case "manjaro": distroIcon = "manjaro-symbolic"; break;
                case "endeavouros": distroIcon = "endeavouros-symbolic"; break;
                case "cachyos": distroIcon = "cachyos-symbolic"; break;
                case "nixos": distroIcon = "nixos-symbolic"; break;
                case "fedora": distroIcon = "fedora-symbolic"; break;
                case "linuxmint":
                case "ubuntu":
                case "zorin":
                case "popos": distroIcon = "ubuntu-symbolic"; break;
                case "debian":
                case "raspbian":
                case "kali": distroIcon = "debian-symbolic"; break;
                case "funtoo":
                case "gentoo": distroIcon = "gentoo-symbolic"; break;
                default: distroIcon = "linux-symbolic"; break;
            }
            if (textOsRelease.toLowerCase().includes("nyarch")) {
                distroIcon = "nyarch-symbolic"
            }

            if (logo.trim().length === 0) {
                logo = distroIcon
            }

        }
    }

    Process {
        id: getUsername
        command: ["whoami"]
        stdout: SplitParser {
            onRead: data => {
                root.username = data.trim()
            }
        }
    }

    Process {
        id: getDesktopEnvironment
        running: true
        command: ["bash", "-c", "echo $XDG_CURRENT_DESKTOP,$WAYLAND_DISPLAY"]
        stdout: StdioCollector {
            id: deCollector
            onStreamFinished: {
                const [desktop, wayland] = deCollector.text.split(",")
                root.desktopEnvironment = desktop.trim()
                root.windowingSystem = wayland.trim().length > 0 ? "Wayland" : "X11" // Are there others? 🤔
            }
        }
    }

    FileView {
        id: fileOsRelease
        path: "/etc/os-release"
    }
}