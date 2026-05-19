pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Parses `hyprctl binds -j` and groups binds by the text before the first ':'
// in each bind's description ("Category: action"). Re-runs on Hyprland config
// reload so live keybind edits reflect immediately.
Singleton {
    id: root
    property var keybinds: []
    property var keybindCategories: []

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            if (event.name == "configreloaded") {
                getKeybinds.running = true;
            }
        }
    }

    Process {
        id: getKeybinds
        running: true
        command: ["hyprctl", "binds", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.keybinds = JSON.parse(text);
                    var groups = [];
                    for (var i = 0; i < root.keybinds.length; i++) {
                        var bind = root.keybinds[i].description;
                        var group = bind.substring(0, bind.indexOf(":"));
                        if (!groups.includes(group) && group.length > 0) {
                            groups.push(group);
                        }
                    }
                    root.keybindCategories = groups;
                } catch (e) {
                    console.error("[HyprlandKeybinds] Error parsing keybinds:", e);
                }
            }
        }
    }
}
