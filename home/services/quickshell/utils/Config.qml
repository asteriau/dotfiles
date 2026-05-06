pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Shell source directory (parent of utils/), same pattern as Theme.qml.
    readonly property string shellDir: {
        const u = Qt.resolvedUrl("..").toString();
        return u.replace(/^file:\/\//, "").replace(/\/$/, "");
    }
    readonly property string settingsPath: root.shellDir + "/state/settings.json"

    // Runtime ephemera (never written to disk)
    property var  preferredMonitor: [...Quickshell.screens].sort().reverse()[0]
    property bool showSidebar:          false
    property bool showWorkspaceNumbers: false
    property bool showWallpaperPicker:  false
    // These are here for people who don't have a laptop but still want to contribute
    property bool previewBattery:       false
    property bool previewConnectivity:  false

    // Persistent settings (written to state/settings.json)
    property bool   doNotDisturb:                 false
    property string barPosition:                  "left"
    property bool   barRounding:                  true
    property int    barHeight:                    40
    property int    barWidth:                     46
    property int    sidebarWidth:                 420
    property int    workspacesShown:              10
    property bool   workspaceShowAppIcons:        true
    property bool   workspaceAlwaysShowNumbers:   false
    property bool   workspaceMonochromeIcons:     false
    property string fontFamily:                   "Google Sans Flex"
    property int    iconSize:                     14
    property int    osdWidth:                     200
    property int    osdTimeoutMs:                 1000
    property real   weatherLat:                   44.4268
    property real   weatherLon:                   26.1025
    property string weatherCity:                  "Bucharest"
    property string themeMode:                    "preset"
    property string themePreset:                  "default-dark"
    property string themeMatugenScheme:           "scheme-tonal-spot"
    property bool   themeMatugenDark:             true
    property real   themeMatugenContrast:         0.0
    property string themeMatugenWallpaper:        ""

    // Region selector / screenshot / recording
    property string screenshotSavePath:    ""
    property string recordingSavePath:     ""
    property int    regionCircleStrokeWidth: 3
    property int    regionCirclePadding:    4
    property bool   regionCircleAimLines:   true

    // Save triggers (one per persisted property)
    onDoNotDisturbChanged:               save()
    onBarPositionChanged:                save()
    onBarRoundingChanged:                save()
    onBarHeightChanged:                  save()
    onBarWidthChanged:                   save()
    onSidebarWidthChanged:               save()
    onWorkspacesShownChanged:            save()
    onWorkspaceShowAppIconsChanged:      save()
    onWorkspaceAlwaysShowNumbersChanged: save()
    onWorkspaceMonochromeIconsChanged:   save()
    onFontFamilyChanged:                 save()
    onIconSizeChanged:                   save()
    onOsdWidthChanged:                   save()
    onOsdTimeoutMsChanged:               save()
    onWeatherLatChanged:                 save()
    onWeatherLonChanged:                 save()
    onWeatherCityChanged:                save()
    onThemeModeChanged:                  save()
    onThemePresetChanged:                save()
    onThemeMatugenSchemeChanged:         save()
    onThemeMatugenDarkChanged:           save()
    onThemeMatugenContrastChanged:       save()
    onThemeMatugenWallpaperChanged:      save()
    onScreenshotSavePathChanged:         save()
    onRecordingSavePathChanged:          save()
    onRegionCircleStrokeWidthChanged:    save()
    onRegionCirclePaddingChanged:        save()
    onRegionCircleAimLinesChanged:       save()

    // Cross-cutting tokens (flat, top-level)
    readonly property string userName: "Laura"

    readonly property int  hoverTimeoutMs: 500
    readonly property int  padding: 4
    readonly property real spacing: padding * 3
    readonly property real roundingPower: 2.5

    property bool _loaded: false
    property bool _warnedMissing: false

    function _applySettings(raw: string): void {
        if (!raw || raw.trim().length === 0) {
            root._loaded = true;
            return;
        }
        try {
            const obj = JSON.parse(raw);
            if (!obj || typeof obj !== "object") {
                console.warn("Config: settings.json is not a JSON object — using defaults");
                root._loaded = true;
                return;
            }
            if ("doNotDisturb"               in obj) root.doNotDisturb               = !!obj.doNotDisturb;
            if ("barPosition"                in obj) root.barPosition                = String(obj.barPosition);
            if ("barRounding"                in obj) root.barRounding                = !!obj.barRounding;
            // barHeight and barWidth are fixed — ignore saved values.
            if ("sidebarWidth"               in obj) root.sidebarWidth               = parseInt(obj.sidebarWidth) || root.sidebarWidth;
            if ("workspacesShown"            in obj) root.workspacesShown            = parseInt(obj.workspacesShown) || root.workspacesShown;
            if ("workspaceShowAppIcons"      in obj) root.workspaceShowAppIcons      = !!obj.workspaceShowAppIcons;
            if ("workspaceAlwaysShowNumbers" in obj) root.workspaceAlwaysShowNumbers = !!obj.workspaceAlwaysShowNumbers;
            if ("workspaceMonochromeIcons"   in obj) root.workspaceMonochromeIcons   = !!obj.workspaceMonochromeIcons;
            if ("fontFamily"                 in obj) root.fontFamily                 = String(obj.fontFamily);
            if ("iconSize"                   in obj) root.iconSize                   = parseInt(obj.iconSize)    || root.iconSize;
            if ("osdWidth"                   in obj) root.osdWidth                   = parseInt(obj.osdWidth)    || root.osdWidth;
            if ("osdTimeoutMs"               in obj) root.osdTimeoutMs               = parseInt(obj.osdTimeoutMs) || root.osdTimeoutMs;
            if ("weatherLat"                 in obj) root.weatherLat                 = parseFloat(obj.weatherLat);
            if ("weatherLon"                 in obj) root.weatherLon                 = parseFloat(obj.weatherLon);
            if ("weatherCity"                in obj) root.weatherCity                = String(obj.weatherCity);
            if ("themeMode"                  in obj) root.themeMode                  = String(obj.themeMode);
            if ("themePreset"                in obj) root.themePreset                = String(obj.themePreset);
            if ("themeMatugenScheme"         in obj) root.themeMatugenScheme         = String(obj.themeMatugenScheme);
            if ("themeMatugenDark"           in obj) root.themeMatugenDark           = !!obj.themeMatugenDark;
            if ("themeMatugenContrast"       in obj) root.themeMatugenContrast       = parseFloat(obj.themeMatugenContrast);
            if ("themeMatugenWallpaper"      in obj) root.themeMatugenWallpaper      = String(obj.themeMatugenWallpaper);
            if ("screenshotSavePath"         in obj) root.screenshotSavePath         = String(obj.screenshotSavePath);
            if ("recordingSavePath"          in obj) root.recordingSavePath          = String(obj.recordingSavePath);
            if ("regionCircleStrokeWidth"    in obj) root.regionCircleStrokeWidth    = parseInt(obj.regionCircleStrokeWidth) || root.regionCircleStrokeWidth;
            if ("regionCirclePadding"        in obj) root.regionCirclePadding        = parseInt(obj.regionCirclePadding) || root.regionCirclePadding;
            if ("regionCircleAimLines"       in obj) root.regionCircleAimLines       = !!obj.regionCircleAimLines;
        } catch (e) {
            console.warn("Config: failed to parse settings.json —", e, "— using defaults");
        }
        root._loaded = true;
    }

    function save(): void {
        if (!root._loaded) return;
        saveDebounce.restart();
    }

    function _doSave(): void {
        const obj = {
            doNotDisturb:               root.doNotDisturb,
            barPosition:                root.barPosition,
            barRounding:                root.barRounding,
            sidebarWidth:               root.sidebarWidth,
            workspacesShown:            root.workspacesShown,
            workspaceShowAppIcons:      root.workspaceShowAppIcons,
            workspaceAlwaysShowNumbers: root.workspaceAlwaysShowNumbers,
            workspaceMonochromeIcons:   root.workspaceMonochromeIcons,
            fontFamily:                 root.fontFamily,
            iconSize:                   root.iconSize,
            osdWidth:                   root.osdWidth,
            osdTimeoutMs:               root.osdTimeoutMs,
            weatherLat:                 root.weatherLat,
            weatherLon:                 root.weatherLon,
            weatherCity:                root.weatherCity,
            themeMode:                  root.themeMode,
            themePreset:                root.themePreset,
            themeMatugenScheme:         root.themeMatugenScheme,
            themeMatugenDark:           root.themeMatugenDark,
            themeMatugenContrast:       root.themeMatugenContrast,
            themeMatugenWallpaper:      root.themeMatugenWallpaper,
            screenshotSavePath:         root.screenshotSavePath,
            recordingSavePath:          root.recordingSavePath,
            regionCircleStrokeWidth:    root.regionCircleStrokeWidth,
            regionCirclePadding:        root.regionCirclePadding,
            regionCircleAimLines:       root.regionCircleAimLines
        };
        saveProc.running = false;
        saveProc.command = [
            "sh", "-c",
            "mkdir -p \"$(dirname \"$1\")\" && printf '%s' \"$2\" > \"$1\"",
            "--",
            root.settingsPath,
            JSON.stringify(obj, null, 2)
        ];
        saveProc.running = true;
    }

    FileView {
        id: settingsFile
        path: root.settingsPath
        watchChanges: false
        blockLoading: false
        onLoaded: root._applySettings(settingsFile.text())
        onLoadFailed: err => {
            if (!root._warnedMissing) {
                if (!String(err).includes("No such file") && !String(err).includes("does not exist"))
                    console.warn("Config: could not load settings.json (", err, ") — using defaults");
                root._warnedMissing = true;
            }
            root._loaded = true;
        }
    }

    Timer {
        id: saveDebounce
        interval: 500
        repeat: false
        onTriggered: root._doSave()
    }

    Process {
        id: saveProc
        running: false
    }

    readonly property QtObject bar: QtObject {
        property alias position: root.barPosition
        property alias height:   root.barHeight
        property alias width:    root.barWidth

        readonly property bool vertical: position === "left" || position === "right"
        readonly property bool onEnd:    position === "right" || position === "bottom"
        readonly property int  cornerRadius: 18
        property alias rounding: root.barRounding
    }

    readonly property QtObject sidebar: QtObject {
        property alias width: root.sidebarWidth
    }

    readonly property QtObject workspaces: QtObject {
        property alias shown:             root.workspacesShown
        property alias showAppIcons:      root.workspaceShowAppIcons
        property alias alwaysShowNumbers: root.workspaceAlwaysShowNumbers
        property alias monochromeIcons:   root.workspaceMonochromeIcons
    }

    readonly property QtObject osd: QtObject {
        property alias width:     root.osdWidth
        property alias timeoutMs: root.osdTimeoutMs
    }

    readonly property QtObject island: QtObject {
        readonly property int notchClosedWidth:  185
        readonly property int notchClosedHeight: 32
        readonly property int notchClosedTopRadius:    6
        readonly property int notchClosedBottomRadius: 14

        readonly property int notchOpenTopRadius:      19
        readonly property int notchOpenBottomRadius:   24
        readonly property int expandedWidthHome:   480
        readonly property int expandedHeightHome:  160
        readonly property int expandedWidthMedia:  520
        readonly property int expandedHeightMedia: 160
        readonly property int expandedWidthNotif:  440
        readonly property int expandedHeightNotif: 110
        readonly property int expandedWidthBattery:  440
        readonly property int expandedHeightBattery: 110

        readonly property int compactWidthOsd:    300
        readonly property int osdHeight:          52
        readonly property int osdTopRadius:        notchOpenTopRadius
        readonly property int osdBottomRadius:     osdHeight / 2
        readonly property int compactWidthNotif:  340
        readonly property int compactWidthBattery: 200

        readonly property int mediaArtPeekSize: 22
        readonly property int mediaVizPeekWidth: 36
        readonly property int mediaPeekGap: 6

        readonly property int peekDurationMs:    2200
        readonly property int swapDurationMs:    110
        readonly property int batteryPeekMs:     4000

        readonly property bool alwaysVisible: true
        readonly property bool hoverIdleExpand: true

        readonly property int compactHeight:    notchClosedHeight
        readonly property int expandedHeight:   expandedHeightMedia
        readonly property int notchTopRadius:   notchClosedTopRadius
        readonly property int compactRadius:    notchClosedBottomRadius
        readonly property int expandRadius:     notchOpenBottomRadius
        readonly property int compactWidthMedia: notchClosedWidth + mediaArtPeekSize + mediaVizPeekWidth + 4 * mediaPeekGap
        readonly property int maxWidth: Math.max(expandedWidthMedia, expandedWidthHome, expandedWidthNotif, expandedWidthBattery)
    }

    readonly property QtObject notifications: QtObject {
        readonly property int expireTimeout: 5000
        readonly property int iconSize:      48
        readonly property int width:         360
    }

    readonly property QtObject weather: QtObject {
        property alias lat:  root.weatherLat
        property alias lon:  root.weatherLon
        property alias city: root.weatherCity
    }

    readonly property QtObject theme: QtObject {
        property alias mode:   root.themeMode
        property alias preset: root.themePreset

        readonly property QtObject matugen: QtObject {
            property alias scheme:    root.themeMatugenScheme
            property alias dark:      root.themeMatugenDark
            property alias contrast:  root.themeMatugenContrast
            property alias wallpaper: root.themeMatugenWallpaper
        }
    }

    readonly property QtObject shadow: QtObject {
        readonly property bool enabled:        true
        readonly property real opacity:        0.8
        readonly property int  verticalOffset: 2
        readonly property int  blur:           16
    }

    // Typography scale
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

    // Layout scale
    readonly property QtObject layout: QtObject {
        // Base gap scale
        readonly property int gapXs:  2
        readonly property int gapSm:  4
        readonly property int gapMd:  8
        readonly property int gapLg:  12
        readonly property int gapXl:  16

        // Radii
        readonly property int radiusSm:    8
        readonly property int radiusMd:    12
        readonly property int radiusLg:    16
        readonly property int radiusXl:    22
        readonly property int radiusXxl:   28
        readonly property int cardRadius:  radiusLg
        readonly property int pillRadius:  9999

        // Settings/content
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

        // Control sizes
        readonly property int iconBtnSize:   38
        readonly property int pillSize:      56
        readonly property int tileSize:      56
        readonly property int tileLargeHeight: 84
        readonly property int sliderColumnH: 132

        // Notification/weather tweaks
        readonly property int notificationRadius:        24
        readonly property int notificationCollapsedR:    20
        readonly property int weatherRadius:             22
        readonly property int mediaCardRadius:           22

        // Bar focal slot
        readonly property int focalMaxWidth:  280
        readonly property int focalMinHeight: 28
        readonly property int barZoneGap:     8
    }
}
