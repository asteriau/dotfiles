pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Core palette (edit these to re-theme).
    readonly property color background: "#151515"
    readonly property color foreground: "#E8E3E3"
    readonly property color elevated:   "#1E1E1E"
    readonly property color border:     "#252525"
    readonly property color accent:     "#8DA3B9"
    readonly property color comment:    Qt.rgba(0.91, 0.89, 0.89, 0.5)
    readonly property color red:        "#B66467"
    readonly property color mpris:      "#8C977D"

    // State overlays on light-on-dark surfaces.
    readonly property color transparent: Qt.rgba(0, 0, 0, 0)
    readonly property color hoverFaint:  Qt.rgba(1, 1, 1, 0.04)
    readonly property color hover:       Qt.rgba(1, 1, 1, 0.06)
    readonly property color hoverStrong:    Qt.rgba(1, 1, 1, 0.08)
    readonly property color hoverStrongest: Qt.rgba(1, 1, 1, 0.12)
    readonly property color pressed:        Qt.rgba(1, 1, 1, 0.10)
    readonly property color pressedStrong:  Qt.rgba(1, 1, 1, 0.18)
    readonly property color scrim:       Qt.rgba(0, 0, 0, 0.22)

    // Popup-layer dark surface (opaque enough to mask scene content behind).
    readonly property color popupBackground: Qt.rgba(0x1E / 255, 0x1E / 255, 0x1E / 255, 0.94)

    // Derived.
    readonly property color overlay:      Qt.hsla(0, 0, 0.95, 0.7)
    readonly property color windowShadow: Qt.rgba(0, 0, 0, 0.2)
    readonly property color divider:      Qt.rgba(foreground.r, foreground.g, foreground.b, 0.15)
    readonly property color cardBorder:   Qt.rgba(1, 1, 1, 0.04)

    readonly property color buttonDisabled:      elevated
    readonly property color buttonDisabledHover: Qt.rgba(0.95, 0.95, 0.95, 0.25)

    readonly property color accentHover:   Qt.lighter(accent, 1.10)
    readonly property color accentPressed: Qt.lighter(accent, 1.18)

    // M3 surface containers (tonal elevation).
    readonly property color surfaceContainerLowest:  "#0F1012"
    readonly property color surfaceContainerLow:     "#1A1D21"
    readonly property color surfaceContainer:        "#1E2226"
    readonly property color surfaceContainerHigh:    "#282D32"
    readonly property color surfaceContainerHighest: "#333940"

    // M3 primary (from accent seed).
    readonly property color m3onPrimary:          "#1A2530"
    readonly property color primaryContainer:     "#253240"
    readonly property color m3onPrimaryContainer: "#B5C8D8"

    // M3 secondary.
    readonly property color secondaryContainer:     "#3A4249"
    readonly property color m3onSecondaryContainer: "#DAE2EA"

    // Accent containers.
    readonly property color accentContainer:     "#263545"
    readonly property color accentText:          "#151520"
    readonly property color accentContainerText: "#C8D6E3"

    // M3 surface content.
    readonly property color m3onSurface:         foreground
    readonly property color m3onSurfaceVariant:  "#B0B8C0"
    readonly property color m3onSurfaceInactive: Qt.rgba(m3onSurfaceVariant.r, m3onSurfaceVariant.g, m3onSurfaceVariant.b, 0.55)
    readonly property color m3outline:           "#7A8590"

    // Workspace visuals.
    readonly property color wsGlow:        Qt.rgba(accent.r, accent.g, accent.b, 0.25)
    readonly property color wsOrbFill:     Qt.rgba(secondaryContainer.r, secondaryContainer.g, secondaryContainer.b, 0.7)
    readonly property color wsActiveGlow:  Qt.rgba(accent.r, accent.g, accent.b, 0.35)
    readonly property color wsRingStroke:  Qt.rgba(m3onSurfaceVariant.r, m3onSurfaceVariant.g, m3onSurfaceVariant.b, 0.3)
    readonly property color wsCapsuleFill: Qt.lighter(elevated, 1.05)
    readonly property color wsCapsuleEdge: Qt.darker(elevated, 1.1)
}
