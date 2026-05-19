import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.sidebar.quickToggles.models

QuickToggleModel {
    id: root
    name: "Cloudflare WARP"
    icon: "cloud_lock"
    statusText: toggled ? "Connected" : "Disconnected"
    tooltipText: "Cloudflare WARP (1.1.1.1)"
    toggled: false
    hasMenu: false
    mainAction: () => {
                    if (root.toggled) {
                        root.toggled = false;
                        Quickshell.execDetached(["warp-cli", "disconnect"]);
                    } else {
                        root.toggled = true;
                        Quickshell.execDetached(["warp-cli", "connect"]);
                    }
                }

    Process {
        id: connectProc
        command: ["warp-cli", "connect"]
        onExited: (exitCode, exitStatus) => {
                      if (exitCode !== 0) {
                          Quickshell.execDetached(["notify-send", "Cloudflare WARP",
                                                   "Connection failed. Please inspect manually with the warp-cli command",
                                                   "-a", "Shell"]);
                      }
                  }
    }

    Process {
        id: registrationProc
        command: ["warp-cli", "registration", "new"]
        onExited: (exitCode, exitStatus) => {
                      if (exitCode === 0) {
                          connectProc.running = true;
                      } else {
                          Quickshell.execDetached(["notify-send", "Cloudflare WARP",
                                                   "Registration failed. Please inspect manually with the warp-cli command",
                                                   "-a", "Shell"]);
                      }
                  }
    }

    Process {
        id: fetchActiveState
        running: true
        command: ["bash", "-c", "warp-cli status"]
        stdout: StdioCollector {
            id: warpStatusCollector
            onStreamFinished: {
                if (warpStatusCollector.text.length > 0)
                    root.available = true;
                if (warpStatusCollector.text.includes("Unable"))
                    registrationProc.running = true;
                else if (warpStatusCollector.text.includes("Connected"))
                    root.toggled = true;
                else if (warpStatusCollector.text.includes("Disconnected"))
                    root.toggled = false;
            }
        }
    }
}
