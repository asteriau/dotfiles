import QtQuick
import QtQuick.Effects

Item {
    id: root

    implicitWidth: 32
    implicitHeight: 32

    Image {
        id: img
        anchors.fill: parent
        anchors.margins: 2
        source: Qt.resolvedUrl("../assets/pfp.jpg")
        fillMode: Image.PreserveAspectCrop
        smooth: true
        mipmap: true
        visible: false
    }

    Item {
        id: maskSource
        anchors.fill: img
        visible: false
        layer.enabled: true

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "black"
        }
    }

    MultiEffect {
        anchors.fill: img
        source: img
        maskEnabled: true
        maskSource: maskSource
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }

    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: "#8DA3B9"
        border.width: 1
    }
}
