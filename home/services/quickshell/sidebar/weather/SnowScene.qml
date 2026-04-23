import QtQuick

Item {
    id: scene
    anchors.fill: parent

    Repeater {
        model: 36
        Rectangle {
            id: flake
            property real driftAmp: 8 + Math.random() * 14
            property real driftPhase: Math.random() * 2000
            width: 3 + Math.random() * 2
            height: width
            radius: width / 2
            color: Qt.rgba(1, 1, 1, 0.85)
            antialiasing: true
            x: Math.random() * scene.width + Math.sin(yAnim.position * Math.PI * 2 + driftPhase) * driftAmp
            y: -height

            NumberAnimation {
                id: yAnim
                target: flake
                property: "y"
                from: -10
                to: scene.height + 10
                duration: 5500 + Math.random() * 3000
                loops: Animation.Infinite
                running: true
            }
        }
    }
}
