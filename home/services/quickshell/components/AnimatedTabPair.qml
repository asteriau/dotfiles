import QtQuick
import qs.utils

QtObject {
    id: root
    required property int index
    property real idx1: index
    property real idx2: index

    // Leading edge snaps fast
    Behavior on idx1 {
        NumberAnimation { duration: 180; easing.type: Easing.OutQuart }
    }
    // Trailing edge catches up smoothly
    Behavior on idx2 {
        NumberAnimation { duration: 350; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized }
    }
}
