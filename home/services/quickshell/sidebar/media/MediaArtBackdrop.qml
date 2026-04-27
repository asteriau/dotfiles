import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.utils

// Backdrop for the media card: drop shadow + rounded background + blurred album
// art + alpha tint. The foreground content (art thumbnail, text column, controls)
// is placed through the default content slot and stacks above the blur layers.
Item {
    id: root

    default property alias content: background.data

    property real radius: 0
    property string artSource: ""
    property var colors: null

    RectangularShadow {
        anchors.fill: background
        radius: background.radius
        blur: 18
        offset: Qt.vector2d(0, Config.shadowVerticalOffset)
        spread: 1
        color: Colors.windowShadow
        cached: true
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: 4
        color: root.colors ? ColorMix.applyAlpha(root.colors.colLayer0, 1) : Colors.elevated
        radius: root.radius

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: background.width
                height: background.height
                radius: background.radius
            }
        }

        Image {
            id: blurredArt
            anchors.fill: parent
            source: root.artSource
            sourceSize.width: background.width
            sourceSize.height: background.height
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
            Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic } }
        }

        Rectangle {
            anchors.fill: parent
            color: root.colors ? ColorMix.transparentize(root.colors.colLayer0, 0.3) : "transparent"
            radius: root.radius
        }
    }
}
