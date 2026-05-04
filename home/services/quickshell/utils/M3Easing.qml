pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // M3 emphasized easing curves.
    readonly property list<real> emphasized:       [0.05, 0, 0.133, 0.06, 0.166, 0.4, 0.208, 0.82, 0.25, 1, 1, 1]
    readonly property list<real> emphasizedDecel:  [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property list<real> emphasizedAccel:  [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property list<real> expressiveSpring: [0.42, 1.67, 0.21, 0.90, 1, 1]

    // Canonical duration tokens.
    readonly property int durationInstant: 90
    readonly property int durationShort1:  100
    readonly property int durationShort2:  120
    readonly property int durationShort3:  150
    readonly property int durationShort4:  200
    readonly property int durationMedium1: 250
    readonly property int durationMedium2: 300
    readonly property int durationMedium3: 350
    readonly property int durationLong1:   420
    readonly property int durationLong2:   500

    // Semantic aliases.
    readonly property int spatialDuration: durationMedium3  // element movement
    readonly property int effectsDuration: durationShort4   // opacity, color
    readonly property int pressDuration:   durationShort2   // press/press-release scale
    readonly property int ambientFast:     3500             // ambient breathing (short cycle)
    readonly property int ambientSlow:     6000             // ambient breathing (long cycle: atmosphere/weather)
    readonly property int ambient:         ambientFast      // back-compat alias

    readonly property int expressiveOvershoot: Easing.OutBack

    // ── ii-style expressive curves (for ported StyledSlider/GroupButton) ──
    readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1.00, 1, 1]
    readonly property list<real> expressiveFastSpatial:    [0.42, 1.67, 0.21, 0.90, 1, 1]
    readonly property list<real> expressiveEffects:        [0.34, 0.80, 0.34, 1.00, 1, 1]

    readonly property int elementMoveDuration:     500   // expressiveDefaultSpatial
    readonly property int elementMoveFastDuration: 200   // expressiveEffects
    readonly property int clickBounceDuration:     400
    readonly property int elementMoveFastVelocity: 850
}
