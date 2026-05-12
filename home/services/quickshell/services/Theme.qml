pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Singleton {
    id: root

    // Defaults (reads from default-dark.json unless corrupt, which is why they're also defined here.)
    readonly property var defaults: ({
        "background":              "#151515",
        "foreground":              "#E8E3E3",
        "elevated":                "#1E1E1E",
        "border":                  "#2A2A2A",
        "accent":                  "#8DA3B9",
        "red":                     "#B66467",
        "mpris":                   "#8C977D",
        "surfaceContainerLowest":  "#0E0E0E",
        "surfaceContainerLow":     "#1C1C1C",
        "surfaceContainer":        "#1F1F1F",
        "surfaceContainerHigh":    "#2D2D2D",
        "surfaceContainerHighest": "#383838",
        "primaryContainer":        "#2C3A48",
        "m3onPrimary":             "#131C26",
        "m3onPrimaryContainer":    "#C0D2E2",
        "secondaryContainer":      "#3A3A3A",
        "m3onSecondaryContainer":  "#E0E0E0",
        "accentContainer":         "#2C3A48",
        "accentText":              "#0F0F0F",
        "accentContainerText":     "#C8D6E3",
        "m3onSurfaceVariant":      "#ADADAD",
        "m3outline":               "#6E6E6E"
    })

    property var palette: defaults
    property bool _warnedMissing: false
    property bool _warnedParse:   false

    readonly property string activePath: {
        if (Config.theme.mode === "matugen")
            return Directories.shellDir + "/state/colors.json";
        return Directories.shellDir + "/themes/" + Config.theme.preset + ".json";
    }

    function _val(key: string): string {
        const v = palette ? palette[key] : undefined;
        if (v !== undefined && v !== null && v !== "")
            return v;
        return defaults[key];
    }

    // Exposed palette (consumed by Colors.qml)
    readonly property color background:              _val("background")
    readonly property color foreground:              _val("foreground")
    readonly property color elevated:                _val("elevated")
    readonly property color border:                  _val("border")
    readonly property color accent:                  _val("accent")
    readonly property color red:                     _val("red")
    readonly property color mpris:                   _val("mpris")
    readonly property color surfaceContainerLowest:  _val("surfaceContainerLowest")
    readonly property color surfaceContainerLow:     _val("surfaceContainerLow")
    readonly property color surfaceContainer:        _val("surfaceContainer")
    readonly property color surfaceContainerHigh:    _val("surfaceContainerHigh")
    readonly property color surfaceContainerHighest: _val("surfaceContainerHighest")
    readonly property color primaryContainer:        _val("primaryContainer")
    readonly property color m3onPrimary:             _val("m3onPrimary")
    readonly property color m3onPrimaryContainer:    _val("m3onPrimaryContainer")
    readonly property color secondaryContainer:      _val("secondaryContainer")
    readonly property color m3onSecondaryContainer:  _val("m3onSecondaryContainer")
    readonly property color accentContainer:         _val("accentContainer")
    readonly property color accentText:              _val("accentText")
    readonly property color accentContainerText:     _val("accentContainerText")
    readonly property color m3onSurfaceVariant:      _val("m3onSurfaceVariant")
    readonly property color m3outline:               _val("m3outline")

    // Force a fresh read of the matugen output (used after the process exits,
    // since QFileSystemWatcher can't watch a file that didn't exist at startup).
    function reload(): void {
        if (Config.theme.mode !== "matugen") return;
        reloader.running = false;
        reloader.command = ["cat", Directories.shellDir + "/state/colors.json"];
        reloader.running = true;
    }

    Process {
        id: reloader
        running: false
        stdout: StdioCollector {
            id: reloaderOut
            onStreamFinished: {
                if (reloaderOut.text && reloaderOut.text.length > 0)
                    root._apply(reloaderOut.text);
            }
        }
    }

    // Loader

    // Translate the full M3 snake_case palette (as produced by ii-compatible
    // matugen template) into the internal camelCase palette structure.
    // Preset JSON files use the camelCase format directly and skip this step.
    function _fromM3(m: var): var {
        return {
            background:              m.surface,
            foreground:              m.on_surface,
            elevated:                m.surface_container_low,
            border:                  m.outline_variant,
            accent:                  m.primary,
            red:                     m.error,
            mpris:                   m.tertiary,
            surfaceContainerLowest:  m.surface_container_lowest,
            surfaceContainerLow:     m.surface_container_low,
            surfaceContainer:        m.surface_container,
            surfaceContainerHigh:    m.surface_container_high,
            surfaceContainerHighest: m.surface_container_highest,
            primaryContainer:        m.primary_container,
            m3onPrimary:             m.on_primary,
            m3onPrimaryContainer:    m.on_primary_container,
            secondaryContainer:      m.secondary_container,
            m3onSecondaryContainer:  m.on_secondary_container,
            accentContainer:         m.primary_container,
            accentText:              m.on_primary,
            accentContainerText:     m.on_primary_container,
            m3onSurfaceVariant:      m.on_surface_variant,
            m3outline:               m.outline
        };
    }

    function _apply(raw: string): void {
        if (!raw || raw.length === 0) {
            if (!root._warnedParse) {
                console.warn("Theme: empty JSON at", root.activePath, "— using defaults");
                root._warnedParse = true;
            }
            root.palette = root.defaults;
            return;
        }
        try {
            const obj = JSON.parse(raw);
            if (obj && typeof obj === "object") {
                // M3 snake_case format (matugen output) has a 'surface' key;
                // legacy camelCase preset format has a 'background' key.
                root.palette = ("surface" in obj) ? root._fromM3(obj) : obj;
                root._warnedMissing = false;
                root._warnedParse = false;
            } else {
                if (!root._warnedParse) {
                    console.warn("Theme: non-object JSON at", root.activePath, "— using defaults");
                    root._warnedParse = true;
                }
                root.palette = root.defaults;
            }
        } catch (e) {
            if (!root._warnedParse) {
                console.warn("Theme: failed to parse", root.activePath, "—", e, "— using defaults");
                root._warnedParse = true;
            }
            root.palette = root.defaults;
        }
    }

    FileView {
        id: source
        path: root.activePath
        watchChanges: true
        blockLoading: false

        onLoaded: root._apply(source.text())
        onLoadFailed: err => {
            if (!root._warnedMissing) {
                console.warn("Theme: could not load", root.activePath, "(", err, ") — using defaults");
                root._warnedMissing = true;
            }
            root.palette = root.defaults;
        }
    }

    // Strip the leading "#" off a "#rrggbb" string.
    function _stripHash(s) { return (s && s[0] === "#") ? s.substring(1) : s; }

    // Derived 16-color ANSI block when the preset doesn't supply `_ansi`.
    // Mirrors lib/theme/format.nix:derivedAnsi.
    function _derivedAnsi() {
        const p = palette || defaults;
        const pick = k => _stripHash(p[k] || defaults[k]);
        return {
            black:         pick("surfaceContainerLowest"),
            red:           pick("red"),
            green:         pick("mpris"),
            yellow:        pick("accent"),
            blue:          pick("accent"),
            magenta:       pick("primaryContainer"),
            cyan:          pick("mpris"),
            white:         pick("foreground"),
            brightBlack:   pick("surfaceContainerHigh"),
            brightRed:     pick("red"),
            brightGreen:   pick("mpris"),
            brightYellow:  pick("accent"),
            brightBlue:    pick("accent"),
            brightMagenta: pick("primaryContainer"),
            brightCyan:    pick("mpris"),
            brightWhite:   pick("foreground")
        };
    }

    function _footIniBody() {
        const p = palette || defaults;
        let ansi;
        if (p._ansi) {
            ansi = {};
            for (const k in p._ansi) ansi[k] = _stripHash(p._ansi[k]);
        } else {
            ansi = _derivedAnsi();
        }
        const bg = _stripHash(p.background);
        const fg = _stripHash(p.foreground);
        const accent = _stripHash(p.accent);
        return `[colors]
alpha=1.000000
background=${bg}
foreground=${fg}
regular0=${ansi.black}
regular1=${ansi.red}
regular2=${ansi.green}
regular3=${ansi.yellow}
regular4=${ansi.blue}
regular5=${ansi.magenta}
regular6=${ansi.cyan}
regular7=${ansi.white}
bright0=${ansi.brightBlack}
bright1=${ansi.brightRed}
bright2=${ansi.brightGreen}
bright3=${ansi.brightYellow}
bright4=${ansi.brightBlue}
bright5=${ansi.brightMagenta}
bright6=${ansi.brightCyan}
bright7=${ansi.brightWhite}
selection-foreground=${accent}
selection-background=${bg}
search-box-no-match=${bg} ${ansi.red}
search-box-match=${fg} ${bg}
jump-labels=${bg} ${accent}
urls=${accent}
`;
    }

    function _hyprlandConfBody() {
        const p = palette || defaults;
        const border    = _stripHash(p.border);
        const surfaceCL = _stripHash(p.surfaceContainerLow);
        const elevated  = _stripHash(p.elevated);
        return `general:col.active_border = rgba(${border}77)
general:col.inactive_border = rgba(${surfaceCL}33)
misc:background_color = rgba(${elevated}FF)
`;
    }

    function _writeFootOverlay(): void {
        footWrite.command = [
            "bash", "-c",
            'printf "%s" "$1" > "$2" && pkill -SIGUSR1 foot 2>/dev/null || true',
            "--",
            _footIniBody(),
            Directories.shellDir + "/state/foot.ini"
        ];
        footWrite.running = true;
    }

    function _writeHyprlandOverlay(): void {
        hyprlandWrite.command = [
            "bash", "-c",
            'printf "%s" "$1" > "$2" && hyprctl reload >/dev/null 2>&1 || true',
            "--",
            _hyprlandConfBody(),
            Directories.shellDir + "/state/hyprland.conf"
        ];
        hyprlandWrite.running = true;
    }

    function _writeOverlays(): void {
        _writeFootOverlay();
        _writeHyprlandOverlay();
    }

    Process { id: footWrite; running: false }
    Process { id: hyprlandWrite; running: false }

    // Re-render overlays whenever the resolved palette changes in preset
    // mode. Matugen mode owns its own overlay writes from Matugen.qml.
    onPaletteChanged: {
        if (Config._loaded && Config.theme.mode === "preset") _writeOverlays();
    }

    // Mirror the active preset name + mode to state files so the nix-side
    // theme module (lib/theme) can pick them up on the next rebuild. Foot/
    // GTK/QT/hyprland statics will then reflect the same preset QS is
    // showing; matugen overlay is gated on mode.
    function _writeActivePreset(): void {
        activePresetWriter.command = [
            "bash", "-c",
            'printf "%s\\n" "$1" > "$2"',
            "--",
            Config.theme.preset,
            Directories.shellDir + "/state/active-preset"
        ];
        activePresetWriter.running = true;
    }

    function _writeActiveMode(): void {
        activeModeWriter.command = [
            "bash", "-c",
            'printf "%s\\n" "$1" > "$2"',
            "--",
            Config.theme.mode,
            Directories.shellDir + "/state/active-mode"
        ];
        activeModeWriter.running = true;
    }

    Process { id: activePresetWriter; running: false }
    Process { id: activeModeWriter; running: false }

    Connections {
        target: Config.theme
        function onModeChanged() {
            if (Config._loaded) root._writeActiveMode();
        }
        function onPresetChanged() {
            if (Config._loaded) root._writeActivePreset();
        }
    }

    Component.onCompleted: {
        if (Config._loaded) {
            root._writeActivePreset();
            root._writeActiveMode();
            if (Config.theme.mode === "preset") root._writeOverlays();
        }
    }
}
