import QtQuick
import QtQuick.Effects
import qs.components.shape
import qs.components.surfaces
import qs.sidebar.weather.scene

Item {
    id: scene
    anchors.fill: parent

    property bool isNight: false
    property real parallaxX: 0
    property real parallaxY: 0

    CloudsScene {
        anchors.fill: parent
        isNight: scene.isNight
        stormMode: true
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
    }

    RainScene {
        anchors.fill: parent
        isNight: scene.isNight
        intensityMul: 1.3
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
    }

    ParallaxGroup {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        depth: 0.1

        StormBolt {
            id: bolt
            boltHeight: parent.height * (0.4 + Math.random() * 0.2)
            boltWidth: 32
            x: parent.width * 0.4
            y: 10
        }

        StormBolt {
            id: bolt2
            boltHeight: parent.height * 0.45
            boltWidth: 28
            x: parent.width * 0.55
            y: 10
        }
    }

    Timer {
        id: doubleTimer
        interval: 180
        repeat: false
        onTriggered: {
            bolt2.x = scene.width * (0.25 + Math.random() * 0.5);
            bolt2.flash();
        }
    }

    Timer {
        id: stormTimer
        running: true
        repeat: true
        interval: 3500 + Math.random() * 4500
        onTriggered: {
            bolt.x = scene.width * (0.25 + Math.random() * 0.5);
            bolt.boltHeight = scene.height * (0.4 + Math.random() * 0.2);
            bolt.flash();
            if (Math.random() < 0.22) {
                doubleTimer.interval = 140 + Math.random() * 80;
                doubleTimer.restart();
            }
            stormTimer.interval = 3500 + Math.random() * 4500;
        }
    }

    AtmosphereLayer {
        hazeTop: Qt.rgba(0.05, 0.06, 0.1, 0.3)
        hazeBot: Qt.rgba(0.1, 0.12, 0.18, 0.35)
        vignetteStrength: 0.58
        grainOpacity: 0.0
        breathe: false
    }
}
