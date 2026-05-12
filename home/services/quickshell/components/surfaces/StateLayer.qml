import QtQuick
import qs.utils

// M3 state-layer overlay. 4 states: hover / focus / press / drag.
// Place over an interactive surface; bind hovered/pressed/focused/dragged.
Item {
    id: root

    property real radius: Config.layout.radiusInteractive
    property color tone: Colors.m3onSurface
    property bool hovered: false
    property bool pressed: false
    property bool focused: false
    property bool dragged: false

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        antialiasing: true
        color: root.tone
        opacity: root.dragged ? Config.layout.stateDrag
               : root.pressed ? Config.layout.statePress
               : root.focused ? Config.layout.stateFocus
               : root.hovered ? Config.layout.stateHover
               : 0
        Behavior on opacity {
            NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic }
        }
    }
}
