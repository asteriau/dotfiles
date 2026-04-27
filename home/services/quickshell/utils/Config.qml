pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // ─────────────────────────────────────────────────────────────────────
    //  Everything user-tunable lives on this PersistentProperties block.
    //  It's the single source of truth and persists across shell reloads.
    // ─────────────────────────────────────────────────────────────────────
    PersistentProperties {
        id: persisted
        reloadableId: "persistedStates"

        // Runtime ephemera
        property var preferredMonitor: [...Quickshell.screens].sort().reverse()[0]
        property bool showSidebar: false
        property bool doNotDisturb: false
        property bool showWorkspaceNumbers: false

        // Bar
        property string barPosition: "left"                  // left | right | top | bottom
        property int    barHeight: 40
        property int    barWidth: 52
        property int    sidebarWidth: 420

        // Workspaces
        property int    workspacesShown: 10
        property bool   workspaceShowAppIcons: true
        property bool   workspaceAlwaysShowNumbers: false
        property bool   workspaceMonochromeIcons: false

        // Typography (user-editable family + icon size)
        property string fontFamily: "Google Sans Flex"
        property int    iconSize: 14

        // OSD
        property int    osdWidth: 200
        property int    osdTimeoutMs: 1000
    }

    // ── Aliases (canonical, read + write) ────────────────────────────────
    property alias preferredMonitor:          persisted.preferredMonitor
    property alias showSidebar:               persisted.showSidebar
    property alias doNotDisturb:              persisted.doNotDisturb
    property alias showWorkspaceNumbers:      persisted.showWorkspaceNumbers

    property alias barPosition:               persisted.barPosition
    property alias barHeight:                 persisted.barHeight
    property alias barWidth:                  persisted.barWidth
    property alias sidebarWidth:              persisted.sidebarWidth

    property alias workspacesShown:           persisted.workspacesShown
    property alias workspaceShowAppIcons:     persisted.workspaceShowAppIcons
    property alias workspaceAlwaysShowNumbers:persisted.workspaceAlwaysShowNumbers
    property alias workspaceMonochromeIcons:  persisted.workspaceMonochromeIcons

    property alias fontFamily:                persisted.fontFamily
    property alias iconSize:                  persisted.iconSize

    property alias osdWidth:                  persisted.osdWidth
    property alias osdTimeoutMs:              persisted.osdTimeoutMs

    // ── Derived ──────────────────────────────────────────────────────────
    readonly property bool barVertical: barPosition === "left" || barPosition === "right"
    readonly property bool barOnEnd:    barPosition === "right" || barPosition === "bottom"

    readonly property string userName: "Laura"

    // ── Non-tunable constants ────────────────────────────────────────────
    readonly property int padding: 4
    readonly property real spacing: padding * 3
    readonly property int radius: padding * 4
    readonly property real roundingPower: 2.5

    readonly property int  blurMax: 16
    readonly property real shadowOpacity: 0.8
    readonly property int  shadowVerticalOffset: 2
    readonly property bool shadowEnabled: true

    readonly property int hoverTimeoutMs: 500
    readonly property int notificationExpireTimeout: 5000
    readonly property int notificationIconSize: 48
    readonly property int notificationWidth: 360

    // ── Typography scale ─────────────────────────────────────────────────
    readonly property QtObject typography: QtObject {
        readonly property string family:      root.fontFamily
        readonly property string titleFamily: root.fontFamily
        readonly property int smallest: 10
        readonly property int smaller:  12
        readonly property int smallie:  13
        readonly property int small:    15
        readonly property int normal:   16
        readonly property int large:    17
        readonly property int larger:   19
        readonly property int huge:     22
        readonly property int hugeass:  23
        readonly property int title:    22
        readonly property int titleWeight: Font.Medium
    }

    // ── Layout scale ─────────────────────────────────────────────────────
    readonly property QtObject layout: QtObject {
        readonly property int pageMargin:       20
        readonly property int sectionGap:       30
        readonly property int sectionInner:      8
        readonly property int subsectionGap:     2
        readonly property int rowGap:            4
        readonly property int rowSpacing:        8
        readonly property int rowMinHeight:     44
        readonly property int cardRadius:       16
        readonly property int pillRadius:     9999
        readonly property int sliderRadius:      8
        readonly property int navRailExpanded: 150
        readonly property int navRailCollapsed: 56
        readonly property int contentMaxWidth: 600
    }
}
