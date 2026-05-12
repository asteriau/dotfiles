pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property var preferredMonitor: [...Quickshell.screens].sort().reverse()[0]

    property bool showSidebar:          false
    property bool showWorkspaceNumbers: false
    property bool showWallpaperPicker:  false

    property string sidebarMenu: "none"
}
