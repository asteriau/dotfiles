import QtQuick
import QtQuick.Effects
import qs.modules.common

RectangularShadow {
    required property var target
    anchors.fill: target
    radius: target.radius
    blur: Appearance.elevation.level3.blur
    offset: Qt.vector2d(0.0, Appearance.elevation.level3.y)
    spread: 1
    color: Qt.rgba(0, 0, 0, Appearance.elevation.level3.opacity)
    cached: true
}
