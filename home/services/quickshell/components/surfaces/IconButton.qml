import QtQuick
import qs.components.text
import qs.utils

// Round/pill button with a centered Material Symbol icon.
// `active` switches between accent and surface backgrounds (M3 toggle).
// Hover tint is off by default; set `tintOnHover: true` for idle-hover feedback.
PressablePill {
    id: root

    property string icon
    property real iconPointSize: Config.typography.huge
    property real iconPixelSize: 0                  // when > 0, overrides pointSize
    property real iconFill:   active ? 1 : 0
    property int  iconWeight: active ? 500 : 400
    property int  iconGrade:  -25
    property color colorIcon:       Colors.m3onSurfaceVariant
    property color colorIconActive: Colors.m3onPrimary
    property bool danger: false
    property bool tintOnHover: false

    colorIdle:        Colors.elevated
    colorActive:      danger ? Colors.red : Colors.accent
    colorActiveHover: danger ? Qt.lighter(Colors.red, 1.1) : Colors.accentHover
    colorHover:   tintOnHover ? Colors.hover   : colorIdle
    colorPressed: tintOnHover ? Colors.pressed : colorIdle

    MaterialIcon {
        anchors.centerIn: parent
        text: root.icon
        font.pointSize: root.iconPointSize
        pixelSize: root.iconPixelSize
        fill: root.iconFill
        weight: root.iconWeight
        grade: root.iconGrade
        color: root.active ? root.colorIconActive : root.colorIcon

        Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
    }
}
