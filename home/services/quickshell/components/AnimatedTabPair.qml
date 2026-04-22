import QtQuick
import qs.utils

QtObject {
    id: root
    required property int index
    property real idx1: index
    property real idx2: index

    Behavior on idx1 {
        NumberAnimation { duration: 150; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasizedAccel }
    }
    Behavior on idx2 {
        NumberAnimation { duration: 350; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized }
    }
}
