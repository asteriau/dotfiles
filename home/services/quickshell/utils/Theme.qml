pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

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

    // Shell source directory (parent of utils/), as a plain filesystem path.
    readonly property string shellDir: {
        const u = Qt.resolvedUrl("..").toString();
        return u.replace(/^file:\/\//, "").replace(/\/$/, "");
    }

    readonly property string activePath: {
        if (Config.theme.mode === "matugen")
            return root.shellDir + "/state/colors.json";
        return root.shellDir + "/themes/" + Config.theme.preset + ".json";
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
        reloader.command = ["cat", root.shellDir + "/state/colors.json"];
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

    // When leaving matugen mode, point foot's overlay back at the preset
    // palette (managed by foot.nix). foot.ini already includes state/foot.ini
    // at the top, so we write a nested include here. SIGUSR1 → live reload.
    function _clearFootOverlay(): void {
        footClear.command = [
            "bash", "-c",
            'printf "include = %s/.config/foot/colors.ini\\n" "$HOME" > "$1" && pkill -SIGUSR1 foot 2>/dev/null || true',
            "--",
            root.shellDir + "/state/foot.ini"
        ];
        footClear.running = true;
    }

    // Empty file → hyprland.conf's static general/misc settings win again.
    function _clearHyprlandOverlay(): void {
        hyprlandClear.command = [
            "bash", "-c",
            ': > "$1" && hyprctl reload >/dev/null 2>&1 || true',
            "--",
            root.shellDir + "/state/hyprland.conf"
        ];
        hyprlandClear.running = true;
    }

    function _resetOverlays(): void {
        _clearFootOverlay();
        _clearHyprlandOverlay();
    }

    Process { id: footClear; running: false }
    Process { id: hyprlandClear; running: false }

    Connections {
        target: Config.theme
        function onModeChanged() {
            if (Config.theme.mode === "preset") root._resetOverlays();
        }
    }

    Component.onCompleted: {
        if (Config._loaded && Config.theme.mode === "preset") root._resetOverlays();
    }
}
