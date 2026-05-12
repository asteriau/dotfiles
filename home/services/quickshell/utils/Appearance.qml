pragma Singleton
import QtQuick
import qs.utils

QtObject {
    id: root

    // ─────────────────────────────────────────────────────────────────────
    // Material 3 design tokens (additive — coexist with legacy animation
    // curves below until consumers migrate).
    // ─────────────────────────────────────────────────────────────────────

    // 4dp spacing grid.
    readonly property QtObject spacing: QtObject {
        readonly property int xxs:  2
        readonly property int xs:   4
        readonly property int sm:   8
        readonly property int md:   12
        readonly property int lg:   16
        readonly property int xl:   24
        readonly property int xxl:  32
        readonly property int xxxl: 48
    }

    // M3 shape scale.
    readonly property QtObject radius: QtObject {
        readonly property int none: 0
        readonly property int xs:   4
        readonly property int sm:   8
        readonly property int md:   12
        readonly property int lg:   16
        readonly property int xl:   28
        readonly property int full: 9999
    }

    // M3 elevation tokens. Shadow params per level — opacity / blur / y-offset.
    // Consumers compose with their own DropShadow / Rectangle border.
    readonly property QtObject elevation: QtObject {
        readonly property QtObject level0: QtObject { readonly property real opacity: 0.00; readonly property real blur:  0; readonly property real y: 0 }
        readonly property QtObject level1: QtObject { readonly property real opacity: 0.15; readonly property real blur:  3; readonly property real y: 1 }
        readonly property QtObject level2: QtObject { readonly property real opacity: 0.18; readonly property real blur:  6; readonly property real y: 2 }
        readonly property QtObject level3: QtObject { readonly property real opacity: 0.22; readonly property real blur:  8; readonly property real y: 4 }
        readonly property QtObject level4: QtObject { readonly property real opacity: 0.26; readonly property real blur: 12; readonly property real y: 6 }
        readonly property QtObject level5: QtObject { readonly property real opacity: 0.30; readonly property real blur: 16; readonly property real y: 8 }
    }

    readonly property QtObject motion: QtObject {
        readonly property QtObject duration: QtObject {
            readonly property int instant: 90
            readonly property int short1:  100
            readonly property int short2:  120
            readonly property int short3:  150
            readonly property int short4:  200
            readonly property int medium1: 250
            readonly property int medium2: 300
            readonly property int medium3: 350
            readonly property int long1:   420
            readonly property int long2:   500

            readonly property int spatial:    medium3
            readonly property int effects:    short4
            readonly property int press:      short2
            readonly property int elementMove:     500
            readonly property int elementMoveFast: 200
            readonly property int clickBounce:     400

            readonly property int ambientFast: 3500
            readonly property int ambientSlow: 6000
            readonly property int ambient:     ambientFast
        }
        readonly property QtObject easing: QtObject {
            readonly property list<real> standard:        [0.2, 0.0, 0.0, 1.0, 1, 1]
            readonly property list<real> standardAccel:   [0.3, 0.0, 1.0, 1.0, 1, 1]
            readonly property list<real> standardDecel:   [0.0, 0.0, 0.0, 1.0, 1, 1]
            readonly property list<real> emphasized:      [0.05, 0, 0.133, 0.06, 0.166, 0.4, 0.208, 0.82, 0.25, 1, 1, 1]
            readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
            readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
            readonly property list<real> linear:          [0.0, 0.0, 1.0, 1.0, 1, 1]

            readonly property list<real> expressiveSpring:         [0.42, 1.67, 0.21, 0.90, 1, 1]
            readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1]
            readonly property list<real> expressiveFastSpatial:    [0.42, 1.67, 0.21, 0.90, 1, 1]
            readonly property list<real> expressiveEffects:        [0.34, 0.80, 0.34, 1.00, 1, 1]
        }

        readonly property int expressiveOvershoot:     Easing.OutBack
        readonly property int elementMoveFastVelocity: 850
    }

    // M3 state-layer opacities for hover / focus / pressed / dragged overlays.
    readonly property QtObject state: QtObject {
        readonly property real hover:   0.08
        readonly property real focus:   0.10
        readonly property real pressed: 0.10
        readonly property real dragged: 0.16
    }

    // Strict M3 color roles, sourced from the active palette in Theme.
    // Adds the M3-spec naming surface alongside the legacy `Colors.*` API.
    // Roles missing from the current palette (secondary/tertiary/error
    // containers) are derived from existing entries to avoid touching every
    // preset JSON in this commit.
    readonly property QtObject colors: QtObject {
        // Primary
        readonly property color primary:                 Theme.accent
        readonly property color onPrimary:               Theme.m3onPrimary
        readonly property color primaryContainer:        Theme.primaryContainer
        readonly property color onPrimaryContainer:      Theme.m3onPrimaryContainer

        // Secondary
        readonly property color secondary:               Theme.m3onSurfaceVariant
        readonly property color onSecondary:             Theme.background
        readonly property color secondaryContainer:      Theme.secondaryContainer
        readonly property color onSecondaryContainer:    Theme.m3onSecondaryContainer

        // Tertiary
        readonly property color tertiary:                Theme.mpris
        readonly property color onTertiary:              Theme.background
        readonly property color tertiaryContainer:       Theme.surfaceContainerHigh
        readonly property color onTertiaryContainer:     Theme.foreground

        // Error
        readonly property color error:                   Theme.red
        readonly property color onError:                 Theme.background
        readonly property color errorContainer:          Qt.rgba(Theme.red.r, Theme.red.g, Theme.red.b, 0.18)
        readonly property color onErrorContainer:        Theme.red

        // Surfaces
        readonly property color surface:                 Theme.background
        readonly property color onSurface:               Theme.foreground
        readonly property color surfaceVariant:          Theme.elevated
        readonly property color onSurfaceVariant:        Theme.m3onSurfaceVariant
        readonly property color surfaceContainerLowest:  Theme.surfaceContainerLowest
        readonly property color surfaceContainerLow:     Theme.surfaceContainerLow
        readonly property color surfaceContainer:        Theme.surfaceContainer
        readonly property color surfaceContainerHigh:    Theme.surfaceContainerHigh
        readonly property color surfaceContainerHighest: Theme.surfaceContainerHighest

        // Outlines / overlays
        readonly property color outline:                 Theme.m3outline
        readonly property color outlineVariant:          Theme.border
        readonly property color scrim:                   Qt.rgba(0, 0, 0, 0.22)
        readonly property color shadow:                  Qt.rgba(0, 0, 0, 0.20)

        // Inverse
        readonly property color inverseSurface:          Theme.foreground
        readonly property color onInverseSurface:        Theme.background
        readonly property color inversePrimary:          Qt.lighter(Theme.accent, 1.4)
    }

    // ─────────────────────────────────────────────────────────────────────
    // Legacy animation tokens — preserved for existing consumers. Migrating
    // these to motion.* lands in a later phase.
    // ─────────────────────────────────────────────────────────────────────

    readonly property QtObject animationCurves: QtObject {
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.90, 1, 1]
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1]
        readonly property list<real> expressiveEffects: [0.34, 0.80, 0.34, 1.00, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        
        readonly property real expressiveFastSpatialDuration: 350
        readonly property real expressiveDefaultSpatialDuration: 500
        readonly property real expressiveEffectsDuration: 200
    }

    readonly property QtObject animation: QtObject {
        readonly property QtObject elementMoveSmall: QtObject {
            property int duration: root.animationCurves.expressiveFastSpatialDuration
            property Component numberAnimation: Component {
                NumberAnimation {
                    duration: root.animation.elementMoveSmall.duration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.animationCurves.expressiveFastSpatial
                }
            }
        }

        readonly property QtObject elementMoveFast: QtObject {
            property int duration: root.animationCurves.expressiveEffectsDuration
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementMoveFast.duration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.animationCurves.expressiveEffects
                }
            }
        }

        readonly property QtObject elementMoveEnter: QtObject {
            property int duration: 400
            property Component numberAnimation: Component {
                NumberAnimation {
                    alwaysRunToEnd: true
                    duration: root.animation.elementMoveEnter.duration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: root.animationCurves.emphasizedDecel
                }
            }
        }

        readonly property QtObject scroll: QtObject {
            property int duration: 300
            property int type: Easing.BezierSpline
            property list<real> bezierCurve: [0, 0, 0, 1, 1, 1]
        }
    }
}
