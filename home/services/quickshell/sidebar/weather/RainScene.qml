import QtQuick
import QtQuick.Effects
import qs.components.surfaces
import qs.sidebar.weather.scene

Item {
    id: scene
    anchors.fill: parent

    property bool isNight: false
    property real intensityMul: 1.0
    property real parallaxX: 0
    property real parallaxY: 0

    readonly property color streakColor: isNight
        ? Qt.rgba(0.60, 0.72, 0.95, 1.0)
        : Qt.rgba(0.80, 0.90, 1.0, 1.0)
    readonly property color rippleColor: Qt.rgba(0.78, 0.88, 1.0, 0.5)

    component Streak: Rectangle {
        id: s
        property real len: 20
        property real op: 0.6
        property real dur: 800
        property real baseX: 0

        width: 2.2
        height: len
        radius: width / 2
        antialiasing: true
        color: Qt.rgba(scene.streakColor.r, scene.streakColor.g, scene.streakColor.b, s.op)

        x: baseX

        NumberAnimation on y {
            from: -s.len
            to: scene.height + s.len
            duration: s.dur
            loops: Animation.Infinite
            running: true
        }
    }

    component StreakLayer: ParallaxGroup {
        id: ly
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.35

        property int count: 18
        property real minLen: 14
        property real maxLen: 22
        property real op: 0.5
        property real minDur: 800
        property real maxDur: 1100
        property real layerBlur: 0.0

        Repeater {
            model: ly.count
            Streak {
                baseX: Math.random() * scene.width
                len: ly.minLen + Math.random() * (ly.maxLen - ly.minLen)
                op: ly.op
                dur: (ly.minDur + Math.random() * (ly.maxDur - ly.minDur)) / scene.intensityMul
                Component.onCompleted: y = -len - Math.random() * scene.height
            }
        }

        layer.enabled: ly.layerBlur > 0
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: ly.layerBlur
            blurMax: 8
        }
    }

    Rectangle {
        anchors.fill: parent
        opacity: scene.isNight ? 0.5 : 0.35
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: scene.isNight ? Qt.rgba(0.08, 0.10, 0.16, 0.9) : Qt.rgba(0.35, 0.42, 0.52, 0.6) }
            GradientStop { position: 1.0; color: scene.isNight ? Qt.rgba(0.14, 0.18, 0.26, 0.6) : Qt.rgba(0.48, 0.55, 0.62, 0.3) }
        }
    }

    StreakLayer { count: 18; minLen: 12; maxLen: 16; op: 0.35; minDur: 900; maxDur: 1200; depth: 0.15; layerBlur: 0.5 }
    StreakLayer { count: 20; minLen: 18; maxLen: 24; op: 0.6;  minDur: 700; maxDur: 900;  depth: 0.35; layerBlur: 0.15 }
    StreakLayer { count: 14; minLen: 26; maxLen: 32; op: 0.82; minDur: 500; maxDur: 700;  depth: 0.65; layerBlur: 0.0 }

    // Ripples — Oval discs, two concentric per spawn point
    ParallaxGroup {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.8
        depthY: 0.4

        Repeater {
            model: 4
            Item {
                id: rippleSpot
                property real delay: Math.random() * 2400
                property real cycle: 1600 + Math.random() * 800
                property real baseX: Math.random() * (scene.width - 24)
                x: baseX
                y: scene.height - 14

                Rectangle {
                    id: rOuter
                    anchors.centerIn: parent
                    width: 22
                    height: 8
                    radius: height / 2
                    color: "transparent"
                    border.color: Qt.rgba(scene.rippleColor.r, scene.rippleColor.g, scene.rippleColor.b, 0.35)
                    border.width: 1
                    antialiasing: true
                    opacity: 0
                    scale: 0
                    transformOrigin: Item.Center

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: true
                        PauseAnimation { duration: rippleSpot.delay + 150 }
                        NumberAnimation { from: 0; to: 1.8; duration: 1100; easing.type: Easing.OutCubic }
                        NumberAnimation { to: 0; duration: 1 }
                        PauseAnimation { duration: rippleSpot.cycle - 150 }
                    }
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: true
                        PauseAnimation { duration: rippleSpot.delay + 150 }
                        NumberAnimation { from: 0.45; to: 0; duration: 1100; easing.type: Easing.OutCubic }
                        PauseAnimation { duration: rippleSpot.cycle - 150 }
                    }
                }

                Rectangle {
                    id: rInner
                    anchors.centerIn: parent
                    width: 14
                    height: 5
                    radius: height / 2
                    color: "transparent"
                    border.color: Qt.rgba(scene.rippleColor.r, scene.rippleColor.g, scene.rippleColor.b, 0.55)
                    border.width: 1
                    antialiasing: true
                    opacity: 0
                    scale: 0
                    transformOrigin: Item.Center

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: true
                        PauseAnimation { duration: rippleSpot.delay }
                        NumberAnimation { from: 0; to: 1.5; duration: 1100; easing.type: Easing.OutCubic }
                        NumberAnimation { to: 0; duration: 1 }
                        PauseAnimation { duration: rippleSpot.cycle }
                    }
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: true
                        PauseAnimation { duration: rippleSpot.delay }
                        NumberAnimation { from: 0.6; to: 0; duration: 1100; easing.type: Easing.OutCubic }
                        PauseAnimation { duration: rippleSpot.cycle }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0.7, 0.82, 1.0, 0.08) }
        }
    }

    AtmosphereLayer {
        hazeTop: scene.isNight ? Qt.rgba(0.05, 0.08, 0.14, 0.25) : "transparent"
        hazeBot: Qt.rgba(0.3, 0.4, 0.55, scene.isNight ? 0.3 : 0.15)
        vignetteStrength: scene.isNight ? 0.5 : 0.4
        grainOpacity: 0.0
        breathe: false
    }
}
