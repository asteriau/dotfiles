import QtQuick
import QtQuick.Effects
import qs.components.shape
import qs.components.surfaces
import qs.sidebar.weather.scene
import qs.utils

Item {
    id: scene
    anchors.fill: parent

    property bool isNight: true
    property real parallaxX: 0
    property real parallaxY: 0

    // Deep night mesh
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: Qt.rgba(0.05, 0.06, 0.14, 0.55) }
            GradientStop { position: 0.6; color: Qt.rgba(0.10, 0.13, 0.22, 0.35) }
            GradientStop { position: 1.0; color: Qt.rgba(0.14, 0.13, 0.18, 0.15) }
        }
    }

    // Far stars — depth 0.1
    ParallaxGroup {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.1

        Repeater {
            model: 24
            Rectangle {
                property real baseX: Math.random() * scene.width
                property real baseY: Math.random() * scene.height * 0.75
                width: 1.5 + Math.random() * 1.2
                height: width
                radius: width / 2
                color: Qt.rgba(0.92, 0.94, 1.0, 0.55)
                x: baseX
                y: baseY

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { to: 0.2; duration: 1400 + Math.random() * 1600; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 0.85; duration: 1400 + Math.random() * 1600; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // Aurora ribbon — depth 0.4 (Y parallax dampened)
    ParallaxGroup {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.4
        depthY: 0.25

        MaterialShape {
            id: aurora
            anchors.horizontalCenter: parent.horizontalCenter
            y: scene.height * 0.68
            implicitSize: 80
            shape: MaterialShape.Shape.SoftBurst
            color: Qt.rgba(Colors.accent.r * 0.9, Colors.accent.g * 1.1, 1.0, 0.1)
            transform: Scale {
                xScale: scene.width / 80
                origin.x: 40
                origin.y: 40
            }

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: true
                NumberAnimation { from: 0.4; to: 1.0; duration: 14000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.0; to: 0.4; duration: 14000; easing.type: Easing.InOutSine }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.8
                blurMax: 44
            }
        }
    }

    // Near stars — depth 0.25
    ParallaxGroup {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.25

        Repeater {
            model: 8
            MaterialShape {
                property real baseX: Math.random() * scene.width
                property real baseY: Math.random() * scene.height * 0.6
                implicitSize: 3 + Math.random() * 2.5
                shape: MaterialShape.Shape.Sunny
                color: Qt.rgba(1, 1, 1, 0.95)
                antialiasing: true
                x: baseX
                y: baseY

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { from: 0.7; to: 1.1; duration: 900 + Math.random() * 1200; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.1; to: 0.7; duration: 900 + Math.random() * 1200; easing.type: Easing.InOutSine }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { to: 0.5; duration: 800 + Math.random() * 800; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1.0; duration: 800 + Math.random() * 800; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // Shooting star — arcing diagonal trail
    Item {
        id: shootingStar
        width: 140
        height: 6
        opacity: 0
        rotation: -26
        transformOrigin: Item.Right

        Rectangle {
            id: tail
            width: 130
            height: 2.2
            radius: 1.1
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: head.left
            anchors.rightMargin: -1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.7; color: Qt.rgba(1, 1, 1, 0.55) }
                GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.95) }
            }
            antialiasing: true
        }

        Rectangle {
            id: head
            width: 6
            height: 6
            radius: 3
            color: "white"
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            antialiasing: true

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.6
                blurMax: 20
                brightness: 0.5
            }
        }
    }

    ParallelAnimation {
        id: shootAnim
        NumberAnimation { target: shootingStar; property: "x"; from: scene.width + 60; to: -180; duration: 2600; easing.type: Easing.InOutSine }
        NumberAnimation { target: shootingStar; property: "y"; from: 10 + Math.random() * 30; to: scene.height * 0.55 + Math.random() * 20; duration: 2600; easing.type: Easing.InQuad }
        SequentialAnimation {
            NumberAnimation { target: shootingStar; property: "opacity"; from: 0; to: 1; duration: 280; easing.type: Easing.OutCubic }
            PauseAnimation { duration: 1700 }
            NumberAnimation { target: shootingStar; property: "opacity"; to: 0; duration: 620; easing.type: Easing.InCubic }
        }
    }

    Timer {
        running: true
        repeat: true
        interval: 14000 + Math.random() * 20000
        onTriggered: {
            shootAnim.restart();
            interval = 14000 + Math.random() * 20000;
        }
    }

    // Moon hero — depth 0.6
    ParallaxGroup {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.6

        Item {
            id: moon
            x: parent.width - 100
            y: 88
            width: 0
            height: 0

            // Soft circular glow behind moon
            Rectangle {
                anchors.centerIn: parent
                width: 120
                height: 120
                radius: 60
                color: Qt.rgba(0.95, 0.94, 1.0, 0.28)
                antialiasing: true

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 0.9
                    blurMax: 40
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { from: 0.6; to: 1.0; duration: 3400; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.0; to: 0.6; duration: 3400; easing.type: Easing.InOutSine }
                }
            }

            // Disk — plain round moon
            Rectangle {
                id: moonDisk
                anchors.centerIn: parent
                width: 58
                height: 58
                radius: 29
                color: Qt.rgba(0.97, 0.96, 0.92, 0.98)
                antialiasing: true

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: true
                    NumberAnimation { from: 0.97; to: 1.03; duration: 2600; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.03; to: 0.97; duration: 2600; easing.type: Easing.InOutSine }
                }
            }

            // Craters — plain circles
            Repeater {
                model: [
                    { s: 9, dx: -8, dy: -4 },
                    { s: 6, dx: 6, dy: 3 },
                    { s: 5, dx: -2, dy: 10 }
                ]
                Rectangle {
                    required property var modelData
                    required property int index
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: modelData.dx
                    anchors.verticalCenterOffset: modelData.dy
                    width: modelData.s
                    height: modelData.s
                    radius: modelData.s / 2
                    color: Qt.rgba(0.58, 0.58, 0.62, 0.22)
                    antialiasing: true
                    scale: moonDisk.scale
                }
            }

            // Rim highlight
            Rectangle {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -2
                anchors.verticalCenterOffset: -2
                width: 58
                height: 58
                radius: 29
                color: "transparent"
                border.width: 1.2
                border.color: Qt.rgba(1, 0.98, 0.88, 0.42)
                opacity: 0.7
            }
        }
    }

    AtmosphereLayer {
        hazeTop: "transparent"
        hazeBot: Qt.rgba(0.05, 0.06, 0.14, 0.4)
        vignetteStrength: 0.48
        grainOpacity: 0.0
        breathe: false
    }
}
