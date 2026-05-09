pragma Singleton

import QtQuick
import Quickshell

// Transient UI state. Lives only for the lifetime of the process — never
// persisted to disk. Anything user-tunable belongs in `Config`; anything
// derived from a service/state singleton belongs there. This is the place
// for ephemeral surface-visibility flags and runtime-resolved references.
Singleton {
    id: root

    // Default monitor for surface placement (last in connected-screen order).
    property var preferredMonitor: [...Quickshell.screens].sort().reverse()[0]

    // Surface-visibility flags toggled by global shortcuts / hover edges.
    property bool showSidebar:          false
    property bool showWorkspaceNumbers: false
    property bool showWallpaperPicker:  false

    // Preview switches for screenshots / contributors who don't have the
    // matching hardware in their session (no laptop battery / no Wi-Fi).
    property bool previewBattery:       false
    property bool previewConnectivity:  false
}
