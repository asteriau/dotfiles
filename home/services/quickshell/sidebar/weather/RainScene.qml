import QtQuick

Item {
    id: scene
    anchors.fill: parent

    Repeater {
        model: 50
        Rectangle {
            width: 1.5
            height: 12 + Math.random() * 8
            radius: 1
            color: Qt.rgba(0.78, 0.88, 1.0, 0.7)
            antialiasing: true
            rotation: -14
            x: Math.random() * scene.width
            y: -height

            NumberAnimation on y {
                from: -20
                to: scene.height + 20
                duration: 600 + Math.random() * 500
                loops: Animation.Infinite
                running: true
            }
        }
    }
}
