import QtQuick
import qs.components.surfaces
import qs.sidebar.weather.scene
import qs.utils

Item {
    id: scene
    anchors.fill: parent

    property bool isNight: false
    property bool stormMode: false
    property real parallaxX: 0
    property real parallaxY: 0

    readonly property color baseTint: stormMode
        ? Qt.rgba(0.28, 0.30, 0.34, 0.95)
        : (isNight ? Qt.rgba(0.55, 0.60, 0.70, 0.90)
                   : Qt.rgba(1.0, 1.0, 1.0, 0.85))
    readonly property color hlTint: stormMode
        ? Qt.rgba(0.42, 0.46, 0.52, 0.95)
        : (isNight ? Qt.rgba(0.76, 0.82, 0.92, 0.9)
                   : Qt.rgba(1.0, 0.98, 0.92, 0.98))
    readonly property color shadowTint: Qt.rgba(0, 0, 0, stormMode ? 0.35 : 0.16)

    DriftLayer {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        cluster: c1
        yFrac: 0.22
        speed: 58000
        depth: 0.2
        layerOpacity: 0.78
        reverse: true
        bobAmp: 4
        bobPeriod: 13000

        CloudCluster {
            id: c1
            cloudSize: 95
            tint: scene.baseTint
            highlightTint: scene.hlTint
            shadowTint: scene.shadowTint
        }
    }

    DriftLayer {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        cluster: c2
        yFrac: 0.48
        speed: 40000
        depth: 0.45
        layerOpacity: 0.95
        reverse: false
        bobAmp: 7
        bobPeriod: 10000

        CloudCluster {
            id: c2
            cloudSize: 150
            tint: scene.baseTint
            highlightTint: scene.hlTint
            shadowTint: scene.shadowTint
        }
    }

    DriftLayer {
        parallaxX: scene.parallaxX
        parallaxY: scene.parallaxY
        cluster: c3
        yFrac: 0.74
        speed: 32000
        depth: 0.7
        layerOpacity: 1.0
        reverse: true
        bobAmp: 5
        bobPeriod: 9000

        CloudCluster {
            id: c3
            cloudSize: 120
            tint: scene.baseTint
            highlightTint: scene.hlTint
            shadowTint: scene.shadowTint
        }
    }

    AtmosphereLayer {
        hazeTop: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.05)
        hazeBot: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.07)
        vignetteStrength: scene.isNight ? 0.42 : 0.3
        grainOpacity: 0.0
        breathe: false
    }
}
