import QtQuick
import QtQuick.Effects
import qs.components
import qs.utils

Item {
    id: scene
    anchors.fill: parent

    property bool isNight: false
    property real parallaxX: 0
    property real parallaxY: 0

    readonly property color flakeColor: isNight
        ? Qt.rgba(0.92, 0.95, 1.0, 1.0)
        : Qt.rgba(1.0, 1.0, 1.0, 1.0)

    // Night sky tint
    Rectangle {
        visible: scene.isNight
        anchors.fill: parent
        opacity: 0.5
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(0.10, 0.13, 0.20, 1.0) }
            GradientStop { position: 1.0; color: Qt.rgba(0.18, 0.22, 0.30, 0.8) }
        }
    }

    component Flake: MaterialShape {
        id: flake
        property real driftAmp: 6 + Math.random() * 14
        property real driftPhase: Math.random() * Math.PI * 2
        property real baseX: Math.random() * scene.width
        property real fallDur: 6000
        property real rotDur: 22000
        property real cycleT: 0

        antialiasing: true
        x: baseX + Math.sin(cycleT * Math.PI * 2 + driftPhase) * driftAmp
        y: -implicitSize

        NumberAnimation on cycleT {
            from: 0; to: 1
            duration: flake.fallDur
            loops: Animation.Infinite
            running: true
        }

        NumberAnimation on y {
            from: -20 - Math.random() * scene.height
            to: scene.height + 20
            duration: flake.fallDur
            loops: Animation.Infinite
            running: true
        }

        RotationAnimator on rotation {
            from: 0
            to: Math.random() > 0.5 ? 360 : -360
            duration: flake.rotDur
            loops: Animation.Infinite
            running: true
        }
    }

    // Back layer — depth 0.15
    Item {
        anchors.fill: parent
        transform: Translate { x: scene.parallaxX * 0.15; y: scene.parallaxY * 0.15 }

        Repeater {
            model: 14
            Flake {
                implicitSize: 5 + Math.random() * 3
                shape: MaterialShape.Shape.Cookie6Sided
                color: Qt.rgba(scene.flakeColor.r, scene.flakeColor.g, scene.flakeColor.b, 0.5)
                fallDur: 11000 + Math.random() * 4000
                rotDur: 22000 + Math.random() * 8000
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.5
            blurMax: 8
        }
    }

    // Front layer — depth 0.45
    Item {
        anchors.fill: parent
        transform: Translate { x: scene.parallaxX * 0.45; y: scene.parallaxY * 0.45 }

        Repeater {
            model: 12
            Flake {
                implicitSize: 9 + Math.random() * 5
                shape: Math.random() > 0.5 ? MaterialShape.Shape.Flower : MaterialShape.Shape.Clover8Leaf
                color: Qt.rgba(scene.flakeColor.r, scene.flakeColor.g, scene.flakeColor.b, 0.9)
                fallDur: 8500 + Math.random() * 3500
                rotDur: 18000 + Math.random() * 10000

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { from: 0.7; to: 1.0; duration: 1500 + Math.random() * 2000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.0; to: 0.7; duration: 1500 + Math.random() * 2000; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // Hero flake
    Item {
        anchors.fill: parent
        transform: Translate { x: scene.parallaxX * 0.85; y: scene.parallaxY * 0.85 }

        Flake {
            implicitSize: 22
            shape: MaterialShape.Shape.Flower
            color: Qt.rgba(scene.flakeColor.r, scene.flakeColor.g, scene.flakeColor.b, 0.95)
            baseX: scene.width * 0.72
            driftAmp: 14
            fallDur: 14000
            rotDur: 26000
        }
    }

    // Ground accumulation hint
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height * 0.1
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: scene.isNight ? Qt.rgba(0.85, 0.90, 1.0, 0.05) : Qt.rgba(1, 1, 1, 0.08) }
        }
    }

    AtmosphereLayer {
        hazeTop: "transparent"
        hazeBot: scene.isNight ? Qt.rgba(0.1, 0.13, 0.2, 0.25) : "transparent"
        vignetteStrength: scene.isNight ? 0.4 : 0.28
        grainOpacity: 0.0
        breathe: false
    }
}
