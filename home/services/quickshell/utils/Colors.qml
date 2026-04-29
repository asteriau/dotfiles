pragma Singleton
import QtQuick
import Quickshell
import qs.utils

// Public color API.
//
// Base palette values come from the `Theme` singleton (see Theme.qml), which
// reads a preset JSON or the matugen output. Derived tokens (state overlays,
// accent shades, workspace visuals, etc.) are computed here from the base
// palette — they do not belong in preset JSON files.
//
// This singleton is the stable public API: call sites stay unchanged when
// swapping the underlying theme source.
Singleton {
    id: root

    // ── Core palette (from Theme) ─────────────────────────────────────────
    readonly property color background: Theme.background
    readonly property color foreground: Theme.foreground
    readonly property color elevated:   Theme.elevated
    readonly property color border:     Theme.border
    readonly property color accent:     Theme.accent
    readonly property color red:        Theme.red
    readonly property color mpris:      Theme.mpris

    // Derived from foreground.
    readonly property color comment:    Qt.rgba(foreground.r, foreground.g, foreground.b, 0.5)

    // State overlays on light-on-dark surfaces.
    readonly property color transparent:    Qt.rgba(0, 0, 0, 0)
    readonly property color hoverFaint:     Qt.rgba(1, 1, 1, 0.04)
    readonly property color hover:          Qt.rgba(1, 1, 1, 0.06)
    readonly property color hoverStrong:    Qt.rgba(1, 1, 1, 0.08)
    readonly property color hoverStrongest: Qt.rgba(1, 1, 1, 0.12)
    readonly property color pressed:        Qt.rgba(1, 1, 1, 0.10)
    readonly property color pressedStrong:  Qt.rgba(1, 1, 1, 0.18)
    readonly property color scrim:          Qt.rgba(0, 0, 0, 0.22)

    // Popup-layer surface (derived from elevated).
    readonly property color popupBackground: Qt.rgba(elevated.r, elevated.g, elevated.b, 0.94)

    // Derived.
    readonly property color overlay:        Qt.hsla(0, 0, 0.95, 0.7)
    readonly property color windowShadow:   Qt.rgba(0, 0, 0, 0.2)
    readonly property color divider:        Qt.rgba(foreground.r, foreground.g, foreground.b, 0.15)
    readonly property color outlineVariant: divider
    readonly property color cardBorder:     Qt.rgba(1, 1, 1, 0.04)

    // Tooltip uses inverse-surface tokens (light bg in dark themes, vice
    // versa) so it pops against the panel.
    readonly property color tooltipBg: foreground
    readonly property color tooltipFg: background

    readonly property color buttonDisabled:      elevated
    readonly property color buttonDisabledHover: Qt.rgba(0.95, 0.95, 0.95, 0.25)

    readonly property color accentHover:   Qt.lighter(accent, 1.10)
    readonly property color accentPressed: Qt.lighter(accent, 1.18)

    // M3 surface containers (tonal elevation).
    readonly property color surfaceContainerLowest:  Theme.surfaceContainerLowest
    readonly property color surfaceContainerLow:     Theme.surfaceContainerLow
    readonly property color surfaceContainer:        Theme.surfaceContainer
    readonly property color surfaceContainerHigh:    Theme.surfaceContainerHigh
    readonly property color surfaceContainerHighest: Theme.surfaceContainerHighest

    // M3 primary.
    readonly property color m3onPrimary:          Theme.m3onPrimary
    readonly property color primaryContainer:     Theme.primaryContainer
    readonly property color m3onPrimaryContainer: Theme.m3onPrimaryContainer

    // M3 secondary.
    readonly property color secondaryContainer:     Theme.secondaryContainer
    readonly property color m3onSecondaryContainer: Theme.m3onSecondaryContainer

    // Accent containers.
    readonly property color accentContainer:     Theme.accentContainer
    readonly property color accentText:          Theme.accentText
    readonly property color accentContainerText: Theme.accentContainerText

    // M3 surface content.
    readonly property color m3onSurface:         foreground
    readonly property color m3onSurfaceVariant:  Theme.m3onSurfaceVariant
    readonly property color m3onSurfaceInactive: Qt.rgba(m3onSurfaceVariant.r, m3onSurfaceVariant.g, m3onSurfaceVariant.b, 0.55)
    readonly property color m3outline:           Theme.m3outline

    // Workspace visuals.
    readonly property color wsOrbFill:     Qt.rgba(secondaryContainer.r, secondaryContainer.g, secondaryContainer.b, 0.7)
    readonly property color wsRingStroke:  Qt.rgba(m3onSurfaceVariant.r, m3onSurfaceVariant.g, m3onSurfaceVariant.b, 0.3)
    readonly property color wsCapsuleFill: Qt.lighter(elevated, 1.05)
    readonly property color wsCapsuleEdge: Qt.darker(elevated, 1.1)
}
