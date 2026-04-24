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

    readonly property color puffColor: isNight
        ? Qt.rgba(0.55, 0.60, 0.70, 1.0)
        : Qt.rgba(1.0, 1.0, 1.0, 1.0)

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: scene.isNight ? Qt.rgba(0.18, 0.20, 0.24, 0.4) : Qt.rgba(0.68, 0.67, 0.66, 0.3) }
            GradientStop { position: 1.0; color: scene.isNight ? Qt.rgba(0.22, 0.24, 0.28, 0.5) : Qt.rgba(0.78, 0.78, 0.77, 0.35) }
        }
    }

    component Bank: Item {
        id: bank
        property real yFrac: 0.5
        property real speed: 40000
        property real startX: 0
        property real puffSize: 110
        property real op: 0.14
        property real depth: 0.3
        property bool flip: false

        anchors.fill: parent
        transform: Translate { x: scene.parallaxX * bank.depth; y: scene.parallaxY * bank.depth }

        Item {
            id: cluster
            width: bank.puffSize * 3.8
            height: bank.puffSize
            y: scene.height * bank.yFrac - height / 2

            MaterialShape {
                x: 0
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: bank.puffSize * 1.0
                shape: MaterialShape.Shape.Puffy
                color: Qt.rgba(scene.puffColor.r, scene.puffColor.g, scene.puffColor.b, bank.op)
            }
            Rectangle {
                x: bank.puffSize * 0.55
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -bank.puffSize * 0.08
                width: bank.puffSize * 1.3
                height: bank.puffSize * 0.85
                radius: height / 2
                color: Qt.rgba(scene.puffColor.r, scene.puffColor.g, scene.puffColor.b, bank.op * 0.9)
            }
            MaterialShape {
                x: bank.puffSize * 1.35
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: bank.puffSize * 0.06
                implicitSize: bank.puffSize * 1.15
                shape: MaterialShape.Shape.Puffy
                color: Qt.rgba(scene.puffColor.r, scene.puffColor.g, scene.puffColor.b, bank.op)
            }
            Rectangle {
                x: bank.puffSize * 2.1
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -bank.puffSize * 0.04
                width: bank.puffSize * 1.15
                height: bank.puffSize * 0.8
                radius: height / 2
                color: Qt.rgba(scene.puffColor.r, scene.puffColor.g, scene.puffColor.b, bank.op * 0.95)
            }
            MaterialShape {
                x: bank.puffSize * 2.75
                anchors.verticalCenter: parent.verticalCenter
                implicitSize: bank.puffSize * 0.95
                shape: MaterialShape.Shape.Puffy
                color: Qt.rgba(scene.puffColor.r, scene.puffColor.g, scene.puffColor.b, bank.op)
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.95
                blurMax: 56
            }

            NumberAnimation on x {
                from: bank.flip ? scene.width + cluster.width : -cluster.width
                to: bank.flip ? -cluster.width : scene.width + cluster.width
                duration: bank.speed
                loops: Animation.Infinite
                running: true
                easing.type: Easing.InOutSine
            }
            Component.onCompleted: x = bank.startX
        }
    }

    Bank { yFrac: 0.15; speed: 34000; startX: -80;  puffSize: 100; op: 0.10; depth: 0.15; flip: false }
    Bank { yFrac: 0.38; speed: 52000; startX: 40;   puffSize: 130; op: 0.11; depth: 0.3;  flip: true  }
    Bank { yFrac: 0.62; speed: 38000; startX: -200; puffSize: 120; op: 0.10; depth: 0.5;  flip: false }
    Bank { yFrac: 0.85; speed: 46000; startX: 60;   puffSize: 140; op: 0.10; depth: 0.7;  flip: true  }

    // Haze breath
    Rectangle {
        id: haze
        anchors.fill: parent
        opacity: 0.9
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.5; color: scene.isNight ? Qt.rgba(0.5, 0.55, 0.65, 0.12) : Qt.rgba(1, 1, 1, 0.1) }
            GradientStop { position: 1.0; color: "transparent" }
        }

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: true
            NumberAnimation { from: 0.85; to: 1.0; duration: 6000; easing.type: Easing.InOutSine }
            NumberAnimation { from: 1.0; to: 0.85; duration: 6000; easing.type: Easing.InOutSine }
        }
    }

    AtmosphereLayer {
        hazeTop: scene.isNight ? Qt.rgba(0.15, 0.18, 0.22, 0.2) : Qt.rgba(1, 1, 1, 0.1)
        hazeBot: scene.isNight ? Qt.rgba(0.1, 0.12, 0.16, 0.3) : Qt.rgba(0.8, 0.8, 0.8, 0.1)
        vignetteStrength: 0.5
        grainOpacity: 0.0
        breathe: false
    }
}
