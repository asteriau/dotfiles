import QtQuick
import QtQuick.Effects

Item {
    id: scene
    anchors.fill: parent

    component Band: Rectangle {
        property real speed: 30000
        property real startX: 0
        height: 22
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.18)
        antialiasing: true
        x: startX

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.7
            blurMax: 32
        }

        NumberAnimation on x {
            from: -width
            to: scene.width + width
            duration: speed
            loops: Animation.Infinite
            running: true
        }
    }

    Band { y: 28;  width: 280; speed: 38000; startX: -100 }
    Band { y: 64;  width: 220; speed: 26000; startX: 80 }
    Band { y: 100; width: 320; speed: 44000; startX: -200 }
}
