import QtQuick
import QtQuick.Effects

Item {
    id: scene
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0; color: Qt.rgba(1.0, 0.78, 0.36, 0.55) }
            GradientStop { position: 1; color: Qt.rgba(1.0, 0.92, 0.66, 0.0) }
        }
    }

    Item {
        id: sun
        x: parent.width - 70
        y: -40
        width: 160
        height: 160

        Rectangle {
            anchors.centerIn: parent
            width: 80
            height: 80
            radius: 40
            color: Qt.rgba(1.0, 0.92, 0.55, 0.95)
            antialiasing: true
        }

        Item {
            id: rays
            anchors.centerIn: parent
            width: 160
            height: 160

            Repeater {
                model: 12
                Rectangle {
                    width: 3
                    height: 50
                    radius: 2
                    color: Qt.rgba(1.0, 0.95, 0.65, 0.85)
                    antialiasing: true
                    x: rays.width / 2 - width / 2
                    y: rays.height / 2 - height
                    transformOrigin: Item.Bottom
                    rotation: index * 30
                }
            }

            RotationAnimator on rotation {
                from: 0
                to: 360
                duration: 24000
                loops: Animation.Infinite
                running: true
            }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.6
            blurMax: 32
        }
    }
}
