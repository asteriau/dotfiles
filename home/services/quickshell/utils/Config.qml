pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Persisted settings + non-persisted design tokens.
//
// Persisted state lives under the `JsonAdapter` block: schema is grouped
// (bar, workspaces, sidebar, osd, notifications, weather, theme, typography,
// screenshot). FileView watches `state/config.json` and `onAdapterUpdated`
// debounces writes — adding a setting = adding one property on the relevant
// JsonObject, no save plumbing required.
//
// Non-persisted tokens (island dimensions, layout scale, shadow, typography
// sizing, ephemeral runtime flags) stay as readonly QtObject groups below to
// preserve the existing `Config.<group>.<prop>` consumer surface.
Singleton {
    id: root

    readonly property string shellDir: {
        const u = Qt.resolvedUrl("..").toString();
        return u.replace(/^file:\/\//, "").replace(/\/$/, "");
    }
    readonly property string configPath: root.shellDir + "/state/config.json"
    readonly property string legacyPath: root.shellDir + "/state/settings.json"
    readonly property int    writeDelay: 250

    // Cross-cutting tokens (flat, top-level).
    readonly property string userName: "Laura"
    readonly property int    hoverTimeoutMs: 500
    readonly property int    padding: 4
    readonly property real   spacing: padding * 3
    readonly property real   roundingPower: 2.5

    // Back-compat — FileView serves defaults synchronously, so consumers that
    // gated work on `Config._loaded` see ready state immediately.
    readonly property bool _loaded: true

    Timer {
        id: writeTimer
        interval: root.writeDelay
        repeat: false
        onTriggered: configFile.writeAdapter()
    }

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        onFileChanged: configFile.reload()
        onAdapterUpdated: writeTimer.restart()
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                // First launch — move a legacy flat settings.json aside if
                // present and seed config.json from the adapter defaults.
                legacyMover.running = true;
                configFile.writeAdapter();
            }
        }

        JsonAdapter {
            id: opts

            property JsonObject bar: JsonObject {
                id: barOpts
                property string position: "left"
                property bool   rounding: true
            }

            property JsonObject workspaces: JsonObject {
                id: workspacesOpts
                property int  shown:             10
                property bool showAppIcons:      true
                property bool alwaysShowNumbers: false
                property bool monochromeIcons:   false
                property bool tintedIcons:       false
            }

            property JsonObject sidebar: JsonObject {
                id: sidebarOpts
                property int width: 420
            }

            property JsonObject osd: JsonObject {
                id: osdOpts
                property int width:     200
                property int timeoutMs: 1000
            }

            property JsonObject notifications: JsonObject {
                id: notificationsOpts
                property bool doNotDisturb: false
            }

            property JsonObject weather: JsonObject {
                id: weatherOpts
                property real   lat:  44.4268
                property real   lon:  26.1025
                property string city: "Bucharest"
            }

            property JsonObject theme: JsonObject {
                id: themeOpts
                property string mode:   "preset"
                property string preset: "default-dark"

                property JsonObject matugen: JsonObject {
                    id: matugenOpts
                    property string scheme:    "scheme-tonal-spot"
                    property bool   dark:      true
                    property real   contrast:  0.0
                    property string wallpaper: ""
                }
            }

            property JsonObject typography: JsonObject {
                id: typographyOpts
                property string family:   "Google Sans Flex"
                property int    iconSize: 14
            }

            property JsonObject screenshot: JsonObject {
                id: screenshotOpts
                property string savePath:      ""
                property string recordingPath: ""

                property JsonObject regionCircle: JsonObject {
                    id: regionCircleOpts
                    property int  strokeWidth: 3
                    property int  padding:     4
                    property bool aimLines:    true
                }
            }
        }
    }

    Process {
        id: legacyMover
        running: false
        command: ["sh", "-c", "[ -f \"$1\" ] && mv \"$1\" \"$1.legacy\" || true", "--", root.legacyPath]
    }

    // ── Public grouped wrappers (preserve API shape) ──────────────────────

    readonly property QtObject bar: QtObject {
        property alias position: barOpts.position
        property alias rounding: barOpts.rounding

        readonly property int  height:       40
        readonly property int  width:        46
        readonly property int  cornerRadius: 18
        readonly property bool vertical: position === "left" || position === "right"
        readonly property bool onEnd:    position === "right" || position === "bottom"
    }

    readonly property QtObject sidebar: QtObject {
        property alias width: sidebarOpts.width
    }

    readonly property QtObject workspaces: QtObject {
        property alias shown:             workspacesOpts.shown
        property alias showAppIcons:      workspacesOpts.showAppIcons
        property alias alwaysShowNumbers: workspacesOpts.alwaysShowNumbers
        property alias monochromeIcons:   workspacesOpts.monochromeIcons
        property alias tintedIcons:       workspacesOpts.tintedIcons
    }

    readonly property QtObject osd: QtObject {
        property alias width:     osdOpts.width
        property alias timeoutMs: osdOpts.timeoutMs
    }

    readonly property QtObject island: QtObject {
        readonly property int  notchClosedWidth:  185
        readonly property int  notchClosedHeight: 32
        readonly property int  notchClosedTopRadius:    6
        readonly property int  notchClosedBottomRadius: 14
        readonly property int  notchOpenTopRadius:      19
        readonly property int  notchOpenBottomRadius:   24

        readonly property int  expandedWidthHome:    480
        readonly property int  expandedHeightHome:   160
        readonly property int  expandedWidthMedia:   520
        readonly property int  expandedHeightMedia:  160
        readonly property int  expandedWidthNotif:   440
        readonly property int  expandedHeightNotif:  110
        readonly property int  expandedWidthBattery: 440
        readonly property int  expandedHeightBattery:110

        readonly property int  compactWidthOsd:     300
        readonly property int  osdHeight:           52
        readonly property int  osdTopRadius:         notchOpenTopRadius
        readonly property int  osdBottomRadius:      osdHeight / 2
        readonly property int  compactWidthNotif:   340
        readonly property int  compactWidthBattery: 200

        readonly property int  mediaArtPeekSize:  22
        readonly property int  mediaVizPeekWidth: 36
        readonly property int  mediaPeekGap:      6

        readonly property int  peekDurationMs: 2200
        readonly property int  swapDurationMs: 110
        readonly property int  batteryPeekMs:  4000

        readonly property int  launcherCollapsedWidth: 440
        readonly property int  launcherWidth:          680
        readonly property int  launcherMaxHeight:      560
        readonly property int  launcherMinHeight:      72
        readonly property int  launcherTopRadius:      18
        readonly property int  launcherBottomRadius:   28

        readonly property bool alwaysVisible:    true
        readonly property bool hoverIdleExpand:  true

        readonly property int  compactHeight:    notchClosedHeight
        readonly property int  expandedHeight:   expandedHeightMedia
        readonly property int  notchTopRadius:   notchClosedTopRadius
        readonly property int  compactRadius:    notchClosedBottomRadius
        readonly property int  expandRadius:     notchOpenBottomRadius
        readonly property int  compactWidthMedia: notchClosedWidth + mediaArtPeekSize + mediaVizPeekWidth + 4 * mediaPeekGap
        readonly property int  maxWidth: Math.max(expandedWidthMedia, expandedWidthHome, expandedWidthNotif, expandedWidthBattery, launcherWidth)
    }

    readonly property QtObject notifications: QtObject {
        property alias doNotDisturb: notificationsOpts.doNotDisturb
        readonly property int expireTimeout: 5000
        readonly property int iconSize:      48
        readonly property int width:         360
    }

    readonly property QtObject weather: QtObject {
        property alias lat:  weatherOpts.lat
        property alias lon:  weatherOpts.lon
        property alias city: weatherOpts.city
    }

    readonly property QtObject theme: QtObject {
        property alias mode:   themeOpts.mode
        property alias preset: themeOpts.preset

        readonly property QtObject matugen: QtObject {
            property alias scheme:    matugenOpts.scheme
            property alias dark:      matugenOpts.dark
            property alias contrast:  matugenOpts.contrast
            property alias wallpaper: matugenOpts.wallpaper
        }
    }

    readonly property QtObject shadow: QtObject {
        readonly property bool enabled:        true
        readonly property real opacity:        0.8
        readonly property int  verticalOffset: 2
        readonly property int  blur:           16
    }

    readonly property QtObject typography: QtObject {
        property alias family: typographyOpts.family
        readonly property string titleFamily: family
        readonly property string iconFamily:  "Material Symbols Rounded"

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
        readonly property int titleWeight:    weightMedium
    }

    readonly property QtObject layout: QtObject {
        readonly property int gapXs: 2
        readonly property int gapSm: 4
        readonly property int gapMd: 8
        readonly property int gapLg: 12
        readonly property int gapXl: 16

        readonly property int radiusSm:   8
        readonly property int radiusMd:   12
        readonly property int radiusLg:   16
        readonly property int radiusXl:   22
        readonly property int radiusXxl:  28
        readonly property int cardRadius: radiusLg
        readonly property int pillRadius: 9999

        readonly property int pageMargin:       20
        readonly property int sectionGap:       20
        readonly property int sectionInner:      8
        readonly property int subsectionGap:     2
        readonly property int rowGap:            4
        readonly property int rowSpacing:        8
        readonly property int rowMinHeight:     44
        readonly property int sliderRadius:      8
        readonly property int navRailExpanded:  150
        readonly property int navRailCollapsed:  56
        readonly property int contentMaxWidth:  600

        readonly property int iconBtnSize:      38
        readonly property int pillSize:         56
        readonly property int tileSize:         56
        readonly property int tileLargeHeight:  84
        readonly property int sliderColumnH:   132

        readonly property int notificationRadius:     24
        readonly property int notificationCollapsedR: 20
        readonly property int mediaCardRadius:        22

        readonly property int focalMaxWidth:  280
        readonly property int focalMinHeight:  28
        readonly property int barZoneGap:       8

        readonly property int radiusInteractive: radiusSm
        readonly property int radiusContainer:   radiusMd
        readonly property int radiusBar:         18

        readonly property int interactiveMinV:  40
        readonly property int interactiveMinH:  32
        readonly property int zonePaddingV:     gapXl
        readonly property int zonePaddingH:     gapLg
        readonly property int barWidgetPadding: gapSm

        readonly property real stateHover: 0.08
        readonly property real stateFocus: 0.10
        readonly property real statePress: 0.10
        readonly property real stateDrag:  0.16
    }

    // ── Flat top-level aliases (back-compat for direct readers) ───────────
    property alias barPosition:                  barOpts.position
    property alias barRounding:                  barOpts.rounding
    property alias workspacesShown:              workspacesOpts.shown
    property alias workspaceShowAppIcons:        workspacesOpts.showAppIcons
    property alias workspaceAlwaysShowNumbers:   workspacesOpts.alwaysShowNumbers
    property alias workspaceMonochromeIcons:     workspacesOpts.monochromeIcons
    property alias workspaceTintedIcons:         workspacesOpts.tintedIcons
    property alias sidebarWidth:                 sidebarOpts.width
    property alias osdWidth:                     osdOpts.width
    property alias osdTimeoutMs:                 osdOpts.timeoutMs
    property alias doNotDisturb:                 notificationsOpts.doNotDisturb
    property alias weatherLat:                   weatherOpts.lat
    property alias weatherLon:                   weatherOpts.lon
    property alias weatherCity:                  weatherOpts.city
    property alias themeMode:                    themeOpts.mode
    property alias themePreset:                  themeOpts.preset
    property alias themeMatugenScheme:           matugenOpts.scheme
    property alias themeMatugenDark:             matugenOpts.dark
    property alias themeMatugenContrast:         matugenOpts.contrast
    property alias themeMatugenWallpaper:        matugenOpts.wallpaper
    property alias fontFamily:                   typographyOpts.family
    property alias iconSize:                     typographyOpts.iconSize
    property alias screenshotSavePath:           screenshotOpts.savePath
    property alias recordingSavePath:            screenshotOpts.recordingPath
    property alias regionCircleStrokeWidth:      regionCircleOpts.strokeWidth
    property alias regionCirclePadding:          regionCircleOpts.padding
    property alias regionCircleAimLines:         regionCircleOpts.aimLines
}
