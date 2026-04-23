import QtQuick
import QtQuick.Effects

Item {
    id: scene
    anchors.fill: parent

    component DriftCloud: Item {
        id: c
        property real cloudWidth: 140
        property real cloudHeight: 36
        property real speed: 60000
        property color tint: Qt.rgba(1, 1, 1, 0.55)
        property real startX: 0

        width: cloudWidth
        height: cloudHeight
        x: startX

        Rectangle {
            anchors.centerIn: parent
            width: c.cloudWidth
            height: c.cloudHeight
            radius: height / 2
            color: c.tint
            antialiasing: true
        }
        Rectangle {
            x: c.cloudWidth * 0.25
            y: -c.cloudHeight * 0.4
            width: c.cloudWidth * 0.55
            height: c.cloudHeight * 1.4
            radius: height / 2
            color: c.tint
            antialiasing: true
        }
        Rectangle {
            x: c.cloudWidth * 0.55
            y: -c.cloudHeight * 0.2
            width: c.cloudWidth * 0.4
            height: c.cloudHeight * 1.1
            radius: height / 2
            color: c.tint
            antialiasing: true
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.5
            blurMax: 24
        }

        NumberAnimation on x {
            from: -c.cloudWidth
            to: scene.width + c.cloudWidth
            duration: c.speed
            loops: Animation.Infinite
            running: true
        }
    }

    DriftCloud { y: 18; cloudWidth: 180; cloudHeight: 40; speed: 56000; tint: Qt.rgba(1, 1, 1, 0.45); startX: 60 }
    DriftCloud { y: 56; cloudWidth: 120; cloudHeight: 28; speed: 38000; tint: Qt.rgba(1, 1, 1, 0.6);  startX: -120 }
    DriftCloud { y: 92; cloudWidth: 220; cloudHeight: 48; speed: 72000; tint: Qt.rgba(1, 1, 1, 0.35); startX: -220 }
}
