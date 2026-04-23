import QtQuick
import QtQuick.Effects

Item {
    id: scene
    anchors.fill: parent

    Item {
        id: moon
        x: parent.width - 80
        y: 14
        width: 56
        height: 56

        Rectangle {
            anchors.centerIn: parent
            width: 50
            height: 50
            radius: 25
            color: Qt.rgba(0.93, 0.95, 1.0, 0.95)
            antialiasing: true
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.4
            blurMax: 24
        }
    }

    Repeater {
        model: 22
        Rectangle {
            width: 2
            height: 2
            radius: 1
            color: "white"
            antialiasing: true
            x: Math.random() * scene.width
            y: Math.random() * (scene.height * 0.7)
            opacity: 0.4 + Math.random() * 0.6

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: true
                NumberAnimation { to: 0.15; duration: 800 + Math.random() * 1600; easing.type: Easing.InOutSine }
                NumberAnimation { to: 0.9; duration: 800 + Math.random() * 1600; easing.type: Easing.InOutSine }
            }
        }
    }
}
