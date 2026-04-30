import QtQuick
import QtQuick.Effects
import Quickshell
import qs.utils

// Soft drop-shadow under the pill. Tints toward `accent` when caller passes a
// non-null tint (used for art-themed media). Otherwise neutral window-shadow.
RectangularShadow {
    id: root

    property color tint: Colors.windowShadow
    property real  tintAmount: 0

    radius: 0
    blur:   24
    spread: 1
    offset: Qt.vector2d(0, 6)
    cached: true
    color: tintAmount > 0
        ? Qt.rgba(
            Colors.windowShadow.r * (1 - tintAmount) + tint.r * tintAmount,
            Colors.windowShadow.g * (1 - tintAmount) + tint.g * tintAmount,
            Colors.windowShadow.b * (1 - tintAmount) + tint.b * tintAmount,
            Colors.windowShadow.a * (1 - tintAmount) + tint.a * tintAmount * 0.7)
        : Colors.windowShadow

    Behavior on tintAmount { NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutCubic } }
}
