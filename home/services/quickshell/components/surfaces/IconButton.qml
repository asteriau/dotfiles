import QtQuick
import qs.components.text
import qs.utils

// Round/pill button with a centered Material Symbol icon.
// `active` switches between accent and surface backgrounds (M3 toggle).
// Hover tint is off by default; set `tintOnHover: true` for idle-hover feedback.
PressablePill {
    id: root

    property string icon
    property real iconPointSize: Appearance.typography.huge
    property real iconPixelSize: 0                  // when > 0, overrides pointSize
    property real iconFill:   active ? 1 : 0
    property int  iconWeight: active ? 500 : 400
    property int  iconGrade:  -25
    property color colorIcon:       Appearance.colors.m3onSurfaceVariant
    property color colorIconActive: Appearance.colors.m3onPrimary
    property bool danger: false
    property bool tintOnHover: false

    colorIdle:        Appearance.colors.elevated
    colorActive:      danger ? Appearance.colors.red : Appearance.colors.accent
    colorActiveHover: danger ? Qt.lighter(Appearance.colors.red, 1.1) : Appearance.colors.accentHover
    colorHover:   tintOnHover ? Appearance.colors.hover   : colorIdle
    colorPressed: tintOnHover ? Appearance.colors.pressed : colorIdle

    MaterialIcon {
        anchors.centerIn: parent
        text: root.icon
        font.pointSize: root.iconPointSize
        pixelSize: root.iconPixelSize
        fill: root.iconFill
        weight: root.iconWeight
        grade: root.iconGrade
        color: root.active ? root.colorIconActive : root.colorIcon

        Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }
    }
}
