import QtQuick
import QtQuick.Effects
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property real bodyWidth: 185
    property real bodyHeight: 32
    property real topRadius: 6
    property real bottomRadius: 14

    property color tint: Appearance.colors.windowShadow
    property real tintAmount: 0
    property real shadowOpacity: 0.55
    property int blurAmount: 24
    property int verticalOffset: 6

    readonly property color _color: tintAmount > 0
        ? Qt.rgba(
            Appearance.colors.windowShadow.r * (1 - tintAmount) + tint.r * tintAmount,
            Appearance.colors.windowShadow.g * (1 - tintAmount) + tint.g * tintAmount,
            Appearance.colors.windowShadow.b * (1 - tintAmount) + tint.b * tintAmount,
            1)
        : Appearance.colors.windowShadow

    NotchShape {
        id: shadowShape
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.verticalOffset
        bodyWidth: root.bodyWidth
        bodyHeight: root.bodyHeight
        topRadius: root.topRadius
        bottomRadius: root.bottomRadius
        fillColor: root._color
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: shadowShape
        anchors.horizontalCenterOffset: 0
        source: shadowShape
        blurEnabled: true
        blurMax: 64
        blur: 1.0
        opacity: root.shadowOpacity
    }

    Behavior on tintAmount   { NumberAnimation { duration: Appearance.motion.duration.medium2; easing.type: Easing.OutCubic } }
    Behavior on shadowOpacity { NumberAnimation { duration: Appearance.motion.duration.medium2; easing.type: Easing.OutCubic } }
}
