import QtQuick

Item {
    id: scene
    anchors.fill: parent

    CloudsScene {
        anchors.fill: parent
    }

    RainScene {
        anchors.fill: parent
    }

    Rectangle {
        id: flash
        anchors.fill: parent
        color: "white"
        opacity: 0
    }

    Timer {
        id: flashTimer
        running: true
        repeat: true
        interval: 3000 + Math.random() * 4500
        onTriggered: {
            flashAnim.start();
            flashTimer.interval = 3000 + Math.random() * 4500;
        }
    }

    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: flash; property: "opacity"; to: 0.7; duration: 60 }
        NumberAnimation { target: flash; property: "opacity"; to: 0;   duration: 80 }
        NumberAnimation { target: flash; property: "opacity"; to: 0.9; duration: 50 }
        NumberAnimation { target: flash; property: "opacity"; to: 0;   duration: 350; easing.type: Easing.OutCubic }
    }
}
