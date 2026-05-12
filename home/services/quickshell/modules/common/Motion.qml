pragma Singleton
import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

QtObject {
    component Fade: NumberAnimation {
        duration: Appearance.motion.duration.effects
        easing.type: Easing.OutCubic
    }

    component ColorFade: ColorAnimation {
        duration: Appearance.motion.duration.effects
        easing.type: Easing.OutCubic
    }

    component ColorFadeQuick: ColorAnimation {
        duration: Appearance.motion.duration.effects
    }

    component Spatial: NumberAnimation {
        duration: Appearance.motion.duration.spatial
        easing.type: Easing.OutCubic
    }

    component SpatialEmph: NumberAnimation {
        duration: Appearance.motion.duration.spatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.emphasized
    }

    component Emph: NumberAnimation {
        duration: Appearance.motion.duration.long1
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.emphasized
    }

    component EmphAccel: NumberAnimation {
        duration: Appearance.motion.duration.medium1
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.emphasizedAccel
    }

    component EmphDecel: NumberAnimation {
        duration: Appearance.motion.duration.medium2
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.emphasizedDecel
    }

    component Element: NumberAnimation {
        duration: Appearance.motion.duration.elementMove
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.expressiveDefaultSpatial
    }

    component ElementColor: ColorAnimation {
        duration: Appearance.motion.duration.elementMove
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.expressiveDefaultSpatial
    }

    component ElementFast: NumberAnimation {
        duration: Appearance.motion.duration.elementMoveFast
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.expressiveEffects
    }

    component ElementFastColor: ColorAnimation {
        duration: Appearance.motion.duration.elementMoveFast
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.expressiveEffects
    }
}
