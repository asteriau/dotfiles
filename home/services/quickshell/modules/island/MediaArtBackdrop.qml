import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

// Backdrop for the media card: drop shadow + rounded background + blurred album
// art + alpha tint. The foreground content (art thumbnail, text column, controls)
// is placed through the default content slot and stacks above the blur layers.
Item {
    id: root

    default property alias content: background.data

    property real radius: 0
    property string artSource: ""
    property var colors: null
    property bool showShadow: true
    // Optional external alpha mask. When set, shape comes from this item's
    // rendered alpha instead of the internal rounded rectangle. Caller is
    // responsible for ensuring the item is layer-backed (layer.enabled: true).
    property Item maskSource: null

    RectangularShadow {
        visible: root.showShadow
        anchors.fill: background
        radius: background.radius
        blur: 18
        offset: Qt.vector2d(0, Appearance.shadow.verticalOffset)
        spread: 1
        color: Appearance.colors.windowShadow
        cached: true
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: root.showShadow ? 4 : 0
        color: root.colors ? ColorUtils.applyAlpha(root.colors.colLayer0, 1) : Appearance.colors.elevated
        radius: root.maskSource ? 0 : root.radius

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: root.maskSource ? root.maskSource : internalMask
        }

        Rectangle {
            id: internalMask
            visible: false
            layer.enabled: true
            width: background.width
            height: background.height
            radius: root.radius
        }

        Image {
            id: blurredArt
            anchors.fill: parent
            source: root.artSource
            sourceSize.width: 512
            sourceSize.height: 512
            fillMode: Image.PreserveAspectCrop
            cache: false
            antialiasing: true
            asynchronous: true
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: blurredArt
            saturation: -0.1
            brightness: -0.05
            blurEnabled: true
            blurMax: 64
            blur: 1
            blurMultiplier: 1.4
            opacity: blurredArt.status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.medium3; easing.type: Easing.OutCubic } }
        }

        Rectangle {
            anchors.fill: parent
            color: root.colors ? ColorUtils.transparentize(root.colors.colLayer0, 0.3) : "transparent"
            radius: root.maskSource ? 0 : root.radius
        }
    }
}
