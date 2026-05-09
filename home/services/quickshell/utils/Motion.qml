pragma Singleton
import QtQuick
import qs.utils

// Reusable animation primitives, named for their M3 motion semantics.
//
// Use as the inner animation of a Behavior:
//   Behavior on opacity { Motion.Fade {} }
//   Behavior on color   { Motion.ColorFade {} }
//   Behavior on x       { Motion.Spatial {} }
//
// Override values by adding properties:
//   Behavior on x { Motion.EmphAccel { onRunningChanged: ... } }

QtObject {
    component Fade: NumberAnimation {
        duration: M3Easing.effectsDuration
        easing.type: Easing.OutCubic
    }

    component ColorFade: ColorAnimation {
        duration: M3Easing.effectsDuration
        easing.type: Easing.OutCubic
    }

    component ColorFadeQuick: ColorAnimation {
        duration: M3Easing.effectsDuration
    }

    component Spatial: NumberAnimation {
        duration: M3Easing.spatialDuration
        easing.type: Easing.OutCubic
    }

    component Emph: NumberAnimation {
        duration: M3Easing.durationLong1
        easing.type: Easing.BezierSpline
        easing.bezierCurve: M3Easing.emphasized
    }

    component EmphAccel: NumberAnimation {
        duration: M3Easing.durationMedium1
        easing.type: Easing.BezierSpline
        easing.bezierCurve: M3Easing.emphasizedAccel
    }

    component EmphDecel: NumberAnimation {
        duration: M3Easing.durationMedium2
        easing.type: Easing.BezierSpline
        easing.bezierCurve: M3Easing.emphasizedDecel
    }
}
