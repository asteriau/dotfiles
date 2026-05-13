import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property real radius: Appearance.layout.radiusInteractive
    property real topLeftRadius:     -1
    property real topRightRadius:    -1
    property real bottomLeftRadius:  -1
    property real bottomRightRadius: -1
    property color tone: Appearance.colors.m3onSurface
    property bool hovered: false
    property bool pressed: false
    property bool focused: false
    property bool dragged: false

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        topLeftRadius:     root.topLeftRadius     >= 0 ? root.topLeftRadius     : root.radius
        topRightRadius:    root.topRightRadius    >= 0 ? root.topRightRadius    : root.radius
        bottomLeftRadius:  root.bottomLeftRadius  >= 0 ? root.bottomLeftRadius  : root.radius
        bottomRightRadius: root.bottomRightRadius >= 0 ? root.bottomRightRadius : root.radius
        antialiasing: true
        color: root.tone
        opacity: root.dragged ? Appearance.layout.stateDrag
               : root.pressed ? Appearance.layout.statePress
               : root.focused ? Appearance.layout.stateFocus
               : root.hovered ? Appearance.layout.stateHover
               : 0
        Behavior on opacity {
            NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic }
        }
    }
}
