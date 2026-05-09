pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Polls hyprctl for window + layer geometry. Refresh by calling refresh().
Singleton {
    id: root

    property var windowList: []
    property var layers: ({})

    function refresh() {
        clientsProc.running = false;
        clientsProc.running = true;
        layersProc.running = false;
        layersProc.running = true;
    }

    Process {
        id: clientsProc
        command: ["hyprctl", "-j", "clients"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.windowList = data.map(w => ({
                        address: w.address,
                        class: w.class,
                        title: w.title,
                        floating: w.floating,
                        workspace: { id: w.workspace ? w.workspace.id : 0 },
                        at: w.at,
                        size: w.size,
                    }));
                } catch (e) {
                    console.warn("HyprlandWindowsState: clients parse error", e);
                }
            }
        }
    }

    Process {
        id: layersProc
        command: ["hyprctl", "-j", "layers"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.layers = JSON.parse(text);
                } catch (e) {
                    console.warn("HyprlandWindowsState: layers parse error", e);
                }
            }
        }
    }
}
