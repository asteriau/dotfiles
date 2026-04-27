import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects

Item {
    id: root
    anchors.fill: parent

    property color hazeTop: "transparent"
    property color hazeBot: "transparent"
    property real vignetteStrength: 0.35
    property color vignetteColor: Qt.rgba(0, 0, 0, 1)
    property real grainOpacity: 0.0
    property bool breathe: true

    Rectangle {
        id: haze
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0; color: root.hazeTop }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 1; color: root.hazeBot }
        }
    }

    RadialGradient {
        id: vignette
        anchors.fill: parent
        opacity: root.vignetteStrength
        horizontalRadius: width * 0.75
        verticalRadius: height * 0.95
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.55; color: "transparent" }
            GradientStop { position: 1.0; color: root.vignetteColor }
        }
    }

    Item {
        id: grain
        anchors.fill: parent
        opacity: root.grainOpacity
        visible: root.grainOpacity > 0.001
        Repeater {
            model: 180
            Rectangle {
                width: 1
                height: 1
                color: Math.random() > 0.5 ? "white" : "black"
                opacity: 0.3 + Math.random() * 0.5
                x: Math.random() * grain.width
                y: Math.random() * grain.height
            }
        }
    }

    SequentialAnimation on opacity {
        running: root.breathe
        loops: Animation.Infinite
        NumberAnimation { from: 0.92; to: 1.0; duration: 6000; easing.type: Easing.InOutSine }
        NumberAnimation { from: 1.0; to: 0.92; duration: 6000; easing.type: Easing.InOutSine }
    }
}
