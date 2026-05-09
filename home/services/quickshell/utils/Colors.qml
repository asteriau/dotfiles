pragma Singleton
import QtQuick
import Quickshell
import qs.utils

// Public color API.
//
// Base M3 roles delegate to `Appearance.colors.*` (the canonical surface).
// State-layer overlays, layer aliases (colLayer*), and workspace visuals are
// derived here. Eventual end state: consumers read `Appearance.colors.*` /
// `Appearance.state.*` directly and this file disappears.
Singleton {
    id: root

    // ── Base palette (delegated to Appearance.colors) ─────────────────────
    readonly property color background: Appearance.colors.surface
    readonly property color foreground: Appearance.colors.onSurface
    readonly property color elevated:   Appearance.colors.surfaceVariant
    readonly property color border:     Appearance.colors.outlineVariant
    readonly property color accent:     Appearance.colors.primary
    readonly property color red:        Appearance.colors.error
    readonly property color mpris:      Appearance.colors.tertiary

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
    readonly property color scrim:          Appearance.colors.scrim

    // Popup-layer surface (derived from elevated).
    readonly property color popupBackground: Qt.rgba(elevated.r, elevated.g, elevated.b, 0.94)

    // Derived.
    readonly property color overlay:        Qt.hsla(0, 0, 0.95, 0.7)
    readonly property color windowShadow:   Appearance.colors.shadow
    readonly property color divider:        Qt.rgba(foreground.r, foreground.g, foreground.b, 0.15)
    readonly property color outlineVariant: divider
    readonly property color cardBorder:     Qt.rgba(1, 1, 1, 0.04)

    // Tooltip uses inverse-surface tokens.
    readonly property color tooltipBg: Appearance.colors.inverseSurface
    readonly property color tooltipFg: Appearance.colors.onInverseSurface

    readonly property color buttonDisabled:      elevated
    readonly property color buttonDisabledHover: Qt.rgba(0.95, 0.95, 0.95, 0.25)

    readonly property color accentHover:   Qt.lighter(accent, 1.10)
    readonly property color accentPressed: Qt.lighter(accent, 1.18)

    // M3 surface containers (delegated).
    readonly property color surfaceContainerLowest:  Appearance.colors.surfaceContainerLowest
    readonly property color surfaceContainerLow:     Appearance.colors.surfaceContainerLow
    readonly property color surfaceContainer:        Appearance.colors.surfaceContainer
    readonly property color surfaceContainerHigh:    Appearance.colors.surfaceContainerHigh
    readonly property color surfaceContainerHighest: Appearance.colors.surfaceContainerHighest

    // M3 primary.
    readonly property color m3onPrimary:          Appearance.colors.onPrimary
    readonly property color primaryContainer:     Appearance.colors.primaryContainer
    readonly property color m3onPrimaryContainer: Appearance.colors.onPrimaryContainer

    // M3 secondary.
    readonly property color secondaryContainer:     Appearance.colors.secondaryContainer
    readonly property color m3onSecondaryContainer: Appearance.colors.onSecondaryContainer

    // Accent containers (legacy aliases — no strict M3 equivalent in palette).
    readonly property color accentContainer:     Theme.accentContainer
    readonly property color accentText:          Theme.accentText
    readonly property color accentContainerText: Theme.accentContainerText

    // M3 surface content.
    readonly property color m3onSurface:         Appearance.colors.onSurface
    readonly property color m3onSurfaceVariant:  Appearance.colors.onSurfaceVariant
    readonly property color m3onSurfaceInactive: Qt.rgba(m3onSurfaceVariant.r, m3onSurfaceVariant.g, m3onSurfaceVariant.b, 0.55)
    readonly property color m3outline:           Appearance.colors.outline

    // ── ii-style layer/state aliases ──────────────────────────────────────
    function _mix(a, b, t) {
        return Qt.rgba(a.r * (1 - t) + b.r * t,
                       a.g * (1 - t) + b.g * t,
                       a.b * (1 - t) + b.b * t,
                       a.a * (1 - t) + b.a * t);
    }

    // Layer aliases.
    readonly property color colLayer0:        background
    readonly property color colOnLayer0:      foreground
    readonly property color colLayer1:        surfaceContainerLow
    readonly property color colOnLayer1:      m3onSurfaceVariant
    readonly property color colLayer2:        surfaceContainer
    readonly property color colOnLayer2:      m3onSurface
    readonly property color colLayer3:        surfaceContainerHigh
    readonly property color colOnLayer3:      m3onSurface
    readonly property color colLayer4:        surfaceContainerHighest
    readonly property color colOnLayer4:      m3onSurface

    // Layer state overlays (mix layer + onLayer).
    readonly property color colLayer1Hover:   _mix(colLayer1, colOnLayer1, 0.08)
    readonly property color colLayer1Active:  _mix(colLayer1, colOnLayer1, 0.15)
    readonly property color colLayer2Hover:   _mix(colLayer2, colOnLayer2, 0.08)
    readonly property color colLayer2Active:  _mix(colLayer2, colOnLayer2, 0.15)
    readonly property color colLayer3Hover:   _mix(colLayer3, colOnLayer3, 0.08)
    readonly property color colLayer3Active:  _mix(colLayer3, colOnLayer3, 0.15)

    // Primary state overlays.
    readonly property color colPrimary:        accent
    readonly property color colOnPrimary:      m3onPrimary
    readonly property color colPrimaryHover:   _mix(accent, colLayer1Hover, 0.13)
    readonly property color colPrimaryActive:  _mix(accent, colLayer1Active, 0.30)

    // Secondary container (used by slider unfilled track + dot color).
    readonly property color colSecondaryContainer:    secondaryContainer
    readonly property color colOnSecondaryContainer:  m3onSecondaryContainer
    readonly property color colSecondary:             m3onSurfaceVariant
    readonly property color colOutlineVariant:        outlineVariant

    // Workspace visuals.
    readonly property color wsOrbFill:     Qt.rgba(secondaryContainer.r, secondaryContainer.g, secondaryContainer.b, 0.7)
    readonly property color wsRingStroke:  Qt.rgba(m3onSurfaceVariant.r, m3onSurfaceVariant.g, m3onSurfaceVariant.b, 0.3)
    readonly property color wsCapsuleFill: Qt.lighter(elevated, 1.05)
    readonly property color wsCapsuleEdge: Qt.darker(elevated, 1.1)
}
