import QtQuick
import QtQuick.Effects
import qs.components
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

    component CumulusCluster: Item {
        id: cluster
        property real cloudSize: 120
        property color tint: scene.baseTint
        property color highlightTint: scene.hlTint
        property color shadowTint: scene.shadowTint

        width: cloudSize * 1.7
        height: cloudSize * 1.0

        // Underside shadow — soft rounded rect
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: cluster.cloudSize * 0.2
            width: cluster.cloudSize * 1.4
            height: cluster.cloudSize * 0.55
            radius: height / 2
            color: cluster.shadowTint
        }

        // Body — five Puffy bubbles along arc (lowest center, higher edges)
        MaterialShape {
            x: cluster.cloudSize * 0.0
            y: cluster.cloudSize * 0.32
            implicitSize: cluster.cloudSize * 0.55
            shape: MaterialShape.Shape.Puffy
            color: cluster.tint
        }
        MaterialShape {
            x: cluster.cloudSize * 0.25
            y: cluster.cloudSize * 0.18
            implicitSize: cluster.cloudSize * 0.78
            shape: MaterialShape.Shape.Puffy
            color: cluster.tint
        }
        MaterialShape {
            x: cluster.cloudSize * 0.55
            y: cluster.cloudSize * 0.05
            implicitSize: cluster.cloudSize * 0.92
            shape: MaterialShape.Shape.Puffy
            color: cluster.tint
        }
        MaterialShape {
            x: cluster.cloudSize * 0.95
            y: cluster.cloudSize * 0.18
            implicitSize: cluster.cloudSize * 0.75
            shape: MaterialShape.Shape.Puffy
            color: cluster.tint
        }
        MaterialShape {
            x: cluster.cloudSize * 1.18
            y: cluster.cloudSize * 0.32
            implicitSize: cluster.cloudSize * 0.55
            shape: MaterialShape.Shape.Puffy
            color: cluster.tint
        }

        // Highlight — sun-lit top puff
        MaterialShape {
            x: cluster.cloudSize * 0.6
            y: -cluster.cloudSize * 0.02
            implicitSize: cluster.cloudSize * 0.62
            shape: MaterialShape.Shape.Puffy
            color: cluster.highlightTint
            opacity: 0.55
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.12
            blurMax: 6
            shadowEnabled: true
            shadowBlur: 0.9
            shadowOpacity: 0.28
            shadowVerticalOffset: 10
            shadowColor: "#000000"
        }
    }

    component DriftLayer: Item {
        id: lyr
        property real yFrac: 0.5
        property real cloudSize: 120
        property real speed: 60000
        property real startX: 0
        property real depth: 0.4
        property real layerOpacity: 1.0
        property bool reverse: false
        property real bobAmp: 6
        property int bobPeriod: 11000

        anchors.fill: parent
        transform: Translate { x: scene.parallaxX * lyr.depth; y: scene.parallaxY * lyr.depth }

        CumulusCluster {
            id: cluster
            property real baseY: scene.height * lyr.yFrac - height / 2
            cloudSize: lyr.cloudSize
            opacity: lyr.layerOpacity
            y: baseY

            NumberAnimation on x {
                id: drift
                from: lyr.reverse ? scene.width + cluster.width : -cluster.width
                to: lyr.reverse ? -cluster.width : scene.width + cluster.width
                duration: lyr.speed
                loops: Animation.Infinite
                running: true
                easing.type: Easing.Linear
            }

            SequentialAnimation on y {
                loops: Animation.Infinite
                running: true
                NumberAnimation { from: cluster.baseY; to: cluster.baseY + lyr.bobAmp; duration: lyr.bobPeriod; easing.type: Easing.InOutSine }
                NumberAnimation { from: cluster.baseY + lyr.bobAmp; to: cluster.baseY - lyr.bobAmp; duration: lyr.bobPeriod * 2; easing.type: Easing.InOutSine }
                NumberAnimation { from: cluster.baseY - lyr.bobAmp; to: cluster.baseY; duration: lyr.bobPeriod; easing.type: Easing.InOutSine }
            }

            SequentialAnimation on scale {
                loops: Animation.Infinite
                running: true
                NumberAnimation { from: 0.98; to: 1.02; duration: 7000 + Math.random() * 4000; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.02; to: 0.98; duration: 7000 + Math.random() * 4000; easing.type: Easing.InOutSine }
            }

            Component.onCompleted: {
                drift.from = -cluster.width;
                drift.to = scene.width + cluster.width;
                if (lyr.reverse) {
                    drift.from = scene.width + cluster.width;
                    drift.to = -cluster.width;
                }
                // Stagger phase: jump to random progress
                const span = drift.to - drift.from;
                const offset = Math.random();
                cluster.x = drift.from + span * offset;
            }
        }
    }

    DriftLayer {
        yFrac: 0.22
        cloudSize: 95
        speed: 58000
        startX: 40
        depth: 0.2
        layerOpacity: 0.78
        reverse: true
        bobAmp: 4
        bobPeriod: 13000
    }
    DriftLayer {
        yFrac: 0.48
        cloudSize: 150
        speed: 40000
        startX: -180
        depth: 0.45
        layerOpacity: 0.95
        reverse: false
        bobAmp: 7
        bobPeriod: 10000
    }
    DriftLayer {
        yFrac: 0.74
        cloudSize: 120
        speed: 32000
        startX: -80
        depth: 0.7
        layerOpacity: 1.0
        reverse: true
        bobAmp: 5
        bobPeriod: 9000
    }

    AtmosphereLayer {
        hazeTop: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.05)
        hazeBot: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.07)
        vignetteStrength: scene.isNight ? 0.42 : 0.3
        grainOpacity: 0.0
        breathe: false
    }
}
