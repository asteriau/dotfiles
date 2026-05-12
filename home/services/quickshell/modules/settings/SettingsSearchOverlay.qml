import QtQuick
import qs.modules.common

SearchResultsView {
    id: root

    required property bool active

    opacity: active ? 1 : 0
    visible: opacity > 0

    transform: Translate {
        y: root.active ? 0 : 14
        Behavior on y {
            NumberAnimation {
                duration: Appearance.motion.duration.spatial
                easing.bezierCurve: Appearance.motion.easing.emphasized
                easing.type: Easing.BezierSpline
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.motion.duration.spatial
            easing.bezierCurve: Appearance.motion.easing.emphasized
            easing.type: Easing.BezierSpline
        }
    }
}
