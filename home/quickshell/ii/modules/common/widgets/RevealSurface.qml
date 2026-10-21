import QtQuick
import qs.modules.common

/**
 * Enter/exit motion for a transient surface (overview, OSD, ...): fades,
 * scales from `enterScale` and slides from `enterOffset`. Starts hidden and
 * animates in on its first frame, so a surface created already shown plays
 * its entrance. Flipping `shown` mid-exit reverses the motion, which is why
 * nothing here is alwaysRunToEnd. Direction is read from each Behavior's
 * `targetValue`, so it does not depend on binding order. Set `transformOrigin`
 * for the scale pivot.
 */
Item {
    id: root
    property bool shown: true
    property real enterScale: 0.92
    property point enterOffset: Qt.point(0, 0)

    // Bound only after completion so the first frame is the hidden pose
    property bool _shown: false
    Component.onCompleted: _shown = Qt.binding(() => root.shown)

    opacity: _shown ? 1 : 0
    scale: _shown ? 1 : enterScale
    transform: Translate {
        x: root._shown ? 0 : root.enterOffset.x
        y: root._shown ? 0 : root.enterOffset.y
        Behavior on x {
            id: xBehavior
            animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => xBehavior.targetValue === 0) })
        }
        Behavior on y {
            id: yBehavior
            animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => yBehavior.targetValue === 0) })
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.animation.effectsDefault.duration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.animation.effectsDefault.bezierCurve
        }
    }
    Behavior on scale {
        id: scaleBehavior
        animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => scaleBehavior.targetValue === 1) })
    }
}
