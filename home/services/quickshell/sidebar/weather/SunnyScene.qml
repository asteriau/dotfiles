import QtQuick
import QtQuick.Effects
import qs.components.shape
import qs.components.surfaces
import qs.sidebar.weather.scene
import qs.utils

Item {
    id: scene
    anchors.fill: parent

    property bool isNight: false
    property real parallaxX: 0
    property real parallaxY: 0

    readonly property color accentTint: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.14)

    // Sky mesh: warm peach → cream glow → horizon
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(1.0, 0.72, 0.35, 0.55) }
            GradientStop { position: 0.55; color: Qt.rgba(1.0, 0.88, 0.62, 0.28) }
            GradientStop { position: 1.0; color: Qt.rgba(1.0, 0.94, 0.78, 0.0) }
        }
    }

    // Back hill — depth 0.25, bumpy silhouette
    ParallaxGroup {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.25

        Item {
            id: backHillGroup
            anchors.fill: parent

            // Base sheet
            Rectangle {
                width: parent.width * 1.7
                height: parent.height * 0.55
                radius: width / 2
                color: Qt.rgba(0.24, 0.42, 0.22, 0.85)
                x: -parent.width * 0.35
                y: parent.height * 0.92 - height / 2
                antialiasing: true
            }
            // Bumps
            Repeater {
                model: [
                    { cx: 0.15, w: 220, h: 130 },
                    { cx: 0.55, w: 280, h: 160 },
                    { cx: 0.92, w: 200, h: 120 }
                ]
                Rectangle {
                    required property var modelData
                    width: modelData.w
                    height: modelData.h
                    radius: width / 2
                    color: Qt.rgba(0.24, 0.42, 0.22, 0.85)
                    x: scene.width * modelData.cx - width / 2
                    y: scene.height * 0.78 - height / 2
                    antialiasing: true
                }
            }
        }
    }

    // Front hill — depth 0.5, bumpy + tufts
    ParallaxGroup {
        id: frontHillHost
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.5

        // Base sheet
        Rectangle {
            id: frontHill
            width: parent.width * 1.9
            height: parent.height * 0.5
            radius: width / 2
            color: Qt.rgba(0.32, 0.56, 0.28, 0.97)
            x: -parent.width * 0.45
            y: parent.height * 0.98 - height / 2
            antialiasing: true
        }
        Repeater {
            model: [
                { cx: 0.1, w: 240, h: 140 },
                { cx: 0.42, w: 300, h: 180 },
                { cx: 0.78, w: 260, h: 150 },
                { cx: 1.05, w: 220, h: 130 }
            ]
            Rectangle {
                required property var modelData
                width: modelData.w
                height: modelData.h
                radius: width / 2
                color: Qt.rgba(0.32, 0.56, 0.28, 0.97)
                x: scene.width * modelData.cx - width / 2
                y: scene.height * 0.86 - height / 2
                antialiasing: true
            }
        }

        // Grass tufts along front hill crest
        Repeater {
            model: 11
            Item {
                id: tuft
                required property int index
                property real baseRot: -3 + Math.random() * 6
                property real heightVar: 7 + Math.random() * 6
                width: 4
                height: heightVar
                x: scene.width * (0.04 + index * 0.092) + Math.random() * 8
                y: scene.height * 0.78 - heightVar - 2
                rotation: baseRot
                transformOrigin: Item.Bottom

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 2.5
                    height: tuft.heightVar
                    radius: 1.2
                    color: Qt.rgba(0.22, 0.46, 0.20, 1.0)
                    antialiasing: true
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -2.5
                    width: 2
                    height: tuft.heightVar * 0.8
                    radius: 1
                    color: Qt.rgba(0.22, 0.46, 0.20, 1.0)
                    antialiasing: true
                    rotation: -18
                }
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 2.5
                    width: 2
                    height: tuft.heightVar * 0.8
                    radius: 1
                    color: Qt.rgba(0.22, 0.46, 0.20, 1.0)
                    antialiasing: true
                    rotation: 18
                }

                SequentialAnimation on rotation {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { from: tuft.baseRot - 3; to: tuft.baseRot + 3; duration: 3500 + Math.random() * 1500; easing.type: Easing.InOutSine }
                    NumberAnimation { from: tuft.baseRot + 3; to: tuft.baseRot - 3; duration: 3500 + Math.random() * 1500; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // Distant clouds — parallax depth 0.5 (Y parallax dampened)
    ParallaxGroup {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.5
        depthY: 0.3

        Repeater {
            model: 2
            MaterialShape {
                required property int index
                property real baseY: scene.height * (0.55 + index * 0.15)
                property real speed: 70000 + index * 20000
                implicitSize: 80
                shape: MaterialShape.Shape.Puffy
                color: Qt.rgba(1, 1, 1, 0.22)
                y: baseY

                NumberAnimation on x {
                    from: -implicitSize
                    to: scene.width + implicitSize
                    duration: speed
                    loops: Animation.Infinite
                    running: true
                    easing.type: Easing.InOutSine
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.4
                    blurMax: 18
                }
            }
        }
    }

    // Dust motes — parallax depth 0.15
    ParallaxGroup {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.15

        Repeater {
            model: 14
            Rectangle {
                id: mote
                property real baseX: Math.random() * scene.width
                property real phase: Math.random() * Math.PI * 2
                property real amp: 4 + Math.random() * 6
                property real cycleT: 0
                width: 2 + Math.random() * 1.5
                height: width
                radius: width / 2
                color: Qt.rgba(1.0, 0.95, 0.85, 0.35 + Math.random() * 0.25)
                x: baseX + Math.sin(cycleT * Math.PI * 2 + phase) * amp

                NumberAnimation on cycleT {
                    from: 0; to: 1
                    duration: 6000 + Math.random() * 3000
                    loops: Animation.Infinite
                    running: true
                }

                NumberAnimation on y {
                    from: scene.height + 10
                    to: -10
                    duration: 18000 + Math.random() * 10000
                    loops: Animation.Infinite
                    running: true
                }
            }
        }
    }

    // Ray fan — parallax depth 0.3
    ParallaxGroup {
        id: rayContainer
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.3

        Item {
            id: rays
            x: parent.width - 110
            y: 110
            width: 0
            height: 0

            RotationAnimator on rotation {
                from: 0; to: 360
                duration: 70000
                loops: Animation.Infinite
                running: true
            }

            Repeater {
                model: 8
                Rectangle {
                    width: 2
                    height: 210
                    radius: 1
                    color: Qt.rgba(1.0, 0.93, 0.7, 0.13)
                    antialiasing: true
                    x: -1
                    y: -height
                    transformOrigin: Item.Bottom
                    rotation: index * 45
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.55
                blurMax: 22
            }
        }
    }

    // Sun hero — parallax depth 0.6
    ParallaxGroup {
        id: sunHost
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.6

        Item {
            id: sun
            x: parent.width - 110
            y: 110
            width: 0
            height: 0

            // Outer halo
            MaterialShape {
                anchors.centerIn: parent
                implicitSize: 200
                shape: MaterialShape.Shape.SoftBoom
                color: Qt.rgba(1.0, 0.88, 0.55, 0.45)

                RotationAnimator on rotation {
                    from: 360; to: 0
                    duration: 40000
                    loops: Animation.Infinite
                    running: true
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.65
                    blurMax: 38
                }
            }

            // Petal disk
            MaterialShape {
                id: disk
                anchors.centerIn: parent
                implicitSize: 150
                shape: MaterialShape.Shape.VerySunny
                color: Qt.rgba(1.0, 0.86, 0.38, 0.9)

                RotationAnimator on rotation {
                    from: 0; to: 360
                    duration: 24000
                    loops: Animation.Infinite
                    running: true
                }

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { from: 0.98; to: 1.03; duration: 3200; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.03; to: 0.98; duration: 3200; easing.type: Easing.InOutSine }
                }
            }

            // Inner cap
            MaterialShape {
                anchors.centerIn: parent
                implicitSize: 90
                shape: MaterialShape.Shape.Sunny
                color: Qt.rgba(1.0, 0.96, 0.78, 0.97)
                scale: disk.scale

                RotationAnimator on rotation {
                    from: 0; to: 360
                    duration: 24000
                    loops: Animation.Infinite
                    running: true
                }
            }

            // Specular highlight
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: Qt.rgba(1, 1, 1, 0.6)
                x: -22
                y: -22
                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { from: 0.45; to: 0.75; duration: 3200; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.75; to: 0.45; duration: 3200; easing.type: Easing.InOutSine }
                }

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.6
                    blurMax: 14
                }
            }
        }
    }

    AtmosphereLayer {
        hazeTop: "transparent"
        hazeBot: Qt.rgba(1.0, 0.78, 0.5, 0.1)
        vignetteStrength: 0.28
        vignetteColor: Qt.rgba(0.25, 0.12, 0.05, 1)
        grainOpacity: 0.0
        breathe: false
    }
}
