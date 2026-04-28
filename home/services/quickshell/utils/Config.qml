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

    // ── Runtime ephemera (never written to disk) ───────────────────────────
    property var  preferredMonitor: [...Quickshell.screens].sort().reverse()[0]
    property bool showSidebar:          false
    property bool showWorkspaceNumbers: false
    property bool showWallpaperPicker:  false

    // ── Persistent settings (written to state/settings.json) ──────────────
    property bool   doNotDisturb:                 false
    property string barPosition:                  "left"
    property int    barHeight:                    40
    property int    barWidth:                     52
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

    // ── Save triggers (one per persisted property) ────────────────────────
    onDoNotDisturbChanged:               save()
    onBarPositionChanged:                save()
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

    // ── Cross-cutting tokens (flat, top-level) ─────────────────────────────
    readonly property string userName: "Laura"

    readonly property int  hoverTimeoutMs: 500
    readonly property int  padding: 4
    readonly property real spacing: padding * 3
    readonly property real roundingPower: 2.5

    // ── Persistence internals ─────────────────────────────────────────────
    // Guard: don't write before the initial load completes; the onXxxChanged
    // signals fired during _applySettings would otherwise trigger spurious saves.
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
            if ("barHeight"                  in obj) root.barHeight                  = parseInt(obj.barHeight)    || root.barHeight;
            if ("barWidth"                   in obj) root.barWidth                   = parseInt(obj.barWidth)     || root.barWidth;
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
            barHeight:                  root.barHeight,
            barWidth:                   root.barWidth,
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
            themeMatugenWallpaper:      root.themeMatugenWallpaper
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

    // ── Feature groups ─────────────────────────────────────────────────────

    readonly property QtObject bar: QtObject {
        property alias position: root.barPosition
        property alias height:   root.barHeight
        property alias width:    root.barWidth

        readonly property bool vertical: position === "left" || position === "right"
        readonly property bool onEnd:    position === "right" || position === "bottom"
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
