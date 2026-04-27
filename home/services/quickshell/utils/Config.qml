pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // ── Persisted state (primitives) ───────────────────────────────────────
    // All persisted values live here as flat props so `PersistentProperties`
    // keeps working. The nested `QtObject` groups below expose them via
    // `property alias` so callers get a grouped, feature-scoped API.
    PersistentProperties {
        id: persisted
        reloadableId: "persistedStates"

        // Runtime ephemera.
        property var  preferredMonitor: [...Quickshell.screens].sort().reverse()[0]
        property bool showSidebar: false
        property bool doNotDisturb: false
        property bool showWorkspaceNumbers: false

        // Bar.
        property string barPosition: "left"   // left | right | top | bottom
        property int    barHeight: 40
        property int    barWidth: 52

        // Sidebar.
        property int sidebarWidth: 420

        // Workspaces.
        property int  workspacesShown: 10
        property bool workspaceShowAppIcons: true
        property bool workspaceAlwaysShowNumbers: false
        property bool workspaceMonochromeIcons: false

        // Typography.
        property string fontFamily: "Google Sans Flex"
        property int    iconSize: 14

        // OSD.
        property int osdWidth: 200
        property int osdTimeoutMs: 1000

        // Weather.
        property real   weatherLat: 44.4268
        property real   weatherLon: 26.1025
        property string weatherCity: "Bucharest"
    }

    // ── Runtime ephemera (flat, top-level) ─────────────────────────────────
    property alias preferredMonitor:     persisted.preferredMonitor
    property alias showSidebar:          persisted.showSidebar
    property alias doNotDisturb:         persisted.doNotDisturb
    property alias showWorkspaceNumbers: persisted.showWorkspaceNumbers

    // ── Cross-cutting tokens (flat, top-level) ─────────────────────────────
    property alias fontFamily: persisted.fontFamily
    property alias iconSize:   persisted.iconSize

    readonly property string userName: "Laura"

    readonly property int  hoverTimeoutMs: 500
    readonly property int  padding: 4
    readonly property real spacing: padding * 3
    readonly property real roundingPower: 2.5

    // ── Feature groups ─────────────────────────────────────────────────────

    readonly property QtObject bar: QtObject {
        property alias position: persisted.barPosition
        property alias height:   persisted.barHeight
        property alias width:    persisted.barWidth

        readonly property bool vertical: position === "left" || position === "right"
        readonly property bool onEnd:    position === "right" || position === "bottom"
    }

    readonly property QtObject sidebar: QtObject {
        property alias width: persisted.sidebarWidth
    }

    readonly property QtObject workspaces: QtObject {
        property alias shown:             persisted.workspacesShown
        property alias showAppIcons:      persisted.workspaceShowAppIcons
        property alias alwaysShowNumbers: persisted.workspaceAlwaysShowNumbers
        property alias monochromeIcons:   persisted.workspaceMonochromeIcons
    }

    readonly property QtObject osd: QtObject {
        property alias width:     persisted.osdWidth
        property alias timeoutMs: persisted.osdTimeoutMs
    }

    readonly property QtObject notifications: QtObject {
        readonly property int expireTimeout: 5000
        readonly property int iconSize:      48
        readonly property int width:         360
    }

    readonly property QtObject weather: QtObject {
        property alias lat:  persisted.weatherLat
        property alias lon:  persisted.weatherLon
        property alias city: persisted.weatherCity
    }

    readonly property QtObject shadow: QtObject {
        readonly property bool enabled:        true
        readonly property real opacity:        0.8
        readonly property int  verticalOffset: 2
        readonly property int  blur:           16
    }

    // ── Typography scale ───────────────────────────────────────────────────
    readonly property QtObject typography: QtObject {
        readonly property string family: root.fontFamily
        readonly property string titleFamily: root.fontFamily
        readonly property string iconFamily: "Material Symbols Rounded"

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

        readonly property int weightNormal:   Font.Normal
        readonly property int weightMedium:   Font.Medium
        readonly property int weightDemiBold: Font.DemiBold
        readonly property int weightBold:     Font.Bold

        readonly property int titleWeight: weightMedium
    }

    // ── Layout scale ───────────────────────────────────────────────────────
    readonly property QtObject layout: QtObject {
        // Base gap scale.
        readonly property int gapXs:  2
        readonly property int gapSm:  4
        readonly property int gapMd:  8
        readonly property int gapLg:  12
        readonly property int gapXl:  16

        // Radii.
        readonly property int radiusSm:    8
        readonly property int radiusMd:    12
        readonly property int radiusLg:    16
        readonly property int radiusXl:    22
        readonly property int radiusXxl:   28
        readonly property int cardRadius:  radiusLg
        readonly property int pillRadius:  9999

        // Settings/content.
        readonly property int pageMargin:      20
        readonly property int sectionGap:      30
        readonly property int sectionInner:     8
        readonly property int subsectionGap:    2
        readonly property int rowGap:           4
        readonly property int rowSpacing:       8
        readonly property int rowMinHeight:    44
        readonly property int sliderRadius:     8
        readonly property int navRailExpanded: 150
        readonly property int navRailCollapsed: 56
        readonly property int contentMaxWidth: 600

        // Control sizes.
        readonly property int iconBtnSize:   38
        readonly property int pillSize:      56
        readonly property int tileSize:      56
        readonly property int tileLargeHeight: 84
        readonly property int sliderColumnH: 132

        // Notification/weather tweaks.
        readonly property int notificationRadius:        24
        readonly property int notificationCollapsedR:    20
        readonly property int weatherRadius:             22
        readonly property int mediaCardRadius:           22
    }
}
