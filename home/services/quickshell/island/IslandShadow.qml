import QtQuick
import QtQuick.Effects
import qs.utils

Item {
    id: root

    property real bodyWidth: 185
    property real bodyHeight: 32
    property real topRadius: 6
    property real bottomRadius: 14

    property color tint: Colors.windowShadow
    property real tintAmount: 0
    property real shadowOpacity: 0.55
    property int blurAmount: 24
    property int verticalOffset: 6

    readonly property color _color: tintAmount > 0
        ? Qt.rgba(
            Colors.windowShadow.r * (1 - tintAmount) + tint.r * tintAmount,
            Colors.windowShadow.g * (1 - tintAmount) + tint.g * tintAmount,
            Colors.windowShadow.b * (1 - tintAmount) + tint.b * tintAmount,
            1)
        : Colors.windowShadow

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

    Behavior on tintAmount   { NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutCubic } }
    Behavior on shadowOpacity { NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutCubic } }
}
