pragma ComponentBehavior: Bound
import QtQuick
import qs.utils

Item {
    id: root

    property real progress: 0
    default property Item child
    implicitWidth: child ? child.implicitWidth : 0
    implicitHeight: child ? child.implicitHeight : 0

    children: child ? [child] : []

    property var animation: Appearance.animation.elementMoveSmall.numberAnimation.createObject(this)
    Behavior on progress {
        animation: root.animation
    }
}
