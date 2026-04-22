pragma Singleton

import QtQuick
import Quickshell

Singleton {
    // ── M3 Emphasized easing (signature Google curve) ─────────────────────
    readonly property list<real> emphasized:
        [0.05, 0, 0.133, 0.06, 0.166, 0.4, 0.208, 0.82, 0.25, 1, 1, 1]
    readonly property list<real> emphasizedDecel:
        [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property list<real> emphasizedAccel:
        [0.3, 0, 0.8, 0.15, 1, 1]

    // ── M3 Duration tokens ───────────────────────────────────────────────
    readonly property int durationShort3:  150
    readonly property int durationShort4:  200
    readonly property int durationMedium1: 250
    readonly property int durationMedium2: 300
    readonly property int durationMedium3: 350

    // ── Semantic aliases ─────────────────────────────────────────────────
    readonly property int spatialDuration: durationMedium3   // element movement
    readonly property int effectsDuration: durationShort4    // opacity, color
}
