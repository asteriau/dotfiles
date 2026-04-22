pragma Singleton

import Quickshell

PersistentProperties {
    reloadableId: "persistedStates"

    property var preferredMonitor: {
        return [...Quickshell.screens].sort().reverse()[0];
    }
    property bool showSidebar: false
    property bool doNotDisturb: false
    property bool showWorkspaceNumbers: false

    readonly property string userName: "Laura"

    readonly property int notificationExpireTimeout: 5000
    readonly property int notificationIconSize: 48
    readonly property int notificationWidth: 360
    readonly property int hoverTimeoutMs: 500

    property string barPosition: "left"   // "left" | "right" | "top" | "bottom"
    readonly property bool barVertical: barPosition === "left" || barPosition === "right"
    readonly property bool barOnEnd: barPosition === "right" || barPosition === "bottom"

    readonly property int barHeight: 40
    readonly property int barWidth: 52
    readonly property int sidebarWidth: 420

    readonly property int workspacesShown: 10
    readonly property bool workspaceShowAppIcons: true
    readonly property bool workspaceAlwaysShowNumbers: false
    readonly property bool workspaceMonochromeIcons: false
    readonly property int osdWidth: 200

    readonly property int iconSize: 14
    readonly property real spacing: padding * 3
    readonly property int radius: padding * 4
    readonly property int padding: 4
    readonly property real roundingPower: 2.5

    readonly property int blurMax: 16
    readonly property real shadowOpacity: 0.8
    readonly property int shadowVerticalOffset: 2
    readonly property bool shadowEnabled: true

    readonly property int osdTimeout: 1000
}
