pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property var currentColorScheme: Application.styleHints.colorScheme

    Connections {
        target: Application.styleHints

        // function onColorSchemeChanged(scheme) {
        //     console.log("Color scheme changed to", scheme);
        //     root.currentColorScheme = scheme;
        // }

        function colorSchemeChange() {
            let scheme = Application.styleHints.colorScheme;
            console.log("Color scheme changed to", scheme);
            root.currentColorScheme = scheme;
        }
    }

    property bool darkMode: currentColorScheme !== Qt.ColorScheme.Light

    readonly property color background: "#151515"
    readonly property color foreground: "#E8E3E3"
    readonly property color elevated: "#1E1E1E"
    readonly property color border: "#252525"
    readonly property color mpris: "#8C977D"
    readonly property color foregroundOSD: Qt.hsla(0, 0, 0.95, 0.7)
    readonly property color windowShadow: Qt.rgba(0, 0, 0, 0.2)
    readonly property list<color> monitorColors: ["#8DA3B9", "#D9BC8C", "#8C977D", "#8DA3B9"]

    readonly property color surface: darkMode ? Qt.hsla(0, 0, 0.95, 0.15) : Qt.hsla(0, 0, 0.05, 0.15)
    readonly property color overlay: darkMode ? Qt.hsla(0, 0, 0.95, 0.7) : Qt.hsla(0, 0, 0.05, 0.7)

    readonly property color accent: "#8DA3B9"
    readonly property color comment: Qt.rgba(0.91, 0.89, 0.89, 0.5)
    readonly property color red: "#B66467"

    readonly property color buttonEnabled: accent
    readonly property color buttonEnabledHover: Qt.lighter(accent, 0.9)
    readonly property color buttonDisabled: elevated
    readonly property color buttonDisabledHover: Qt.rgba(surface.r, surface.g, surface.b, surface.a + 0.1)

    // ── M3 Surface containers (tonal elevation, cool-tinted from accent) ──
    readonly property color surfaceContainerLowest: "#0F1012"
    readonly property color surfaceContainerLow:    "#1A1D21"
    readonly property color surfaceContainer:       "#1E2226"
    readonly property color surfaceContainerHigh:   "#282D32"
    readonly property color surfaceContainerHighest:"#333940"

    // ── M3 Primary (from #8DA3B9 seed) ────────────────────────────────────
    readonly property color m3onPrimary: "#1A2530"
    readonly property color primaryContainer:    "#253240"
    readonly property color m3onPrimaryContainer: "#B5C8D8"

    // ── M3 Secondary (desaturated variant) ────────────────────────────────
    readonly property color secondaryContainer:  "#3A4249"
    readonly property color m3onSecondaryContainer: "#DAE2EA"

    // ── M3 Surface content ────────────────────────────────────────────────
    readonly property color m3onSurface:           foreground
    readonly property color m3onSurfaceVariant:    "#B0B8C0"
    readonly property color m3onSurfaceInactive:   Qt.rgba(m3onSurfaceVariant.r, m3onSurfaceVariant.g, m3onSurfaceVariant.b, 0.55)
    readonly property color m3outline:           "#7A8590"
}
