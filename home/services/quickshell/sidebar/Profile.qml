import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.utils

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    Item {
        implicitWidth: 32
        implicitHeight: 32

        Image {
            id: img
            anchors.fill: parent
            source: Qt.resolvedUrl("../assets/pfp.jpg")
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
            visible: false
        }

        Item {
            id: mask
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
            maskSource: mask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }
    }

    Text {
        text: `Hi ${Config.userName}!`
        color: Colors.foreground
        font.family: Config.fontFamily
        font.pixelSize: 18
        font.weight: Font.Light
        verticalAlignment: Text.AlignVCenter
    }

    Item {
        Layout.fillWidth: true
    }

    Text {
        text: UptimeState.uptimeText
        color: Colors.comment
        font.family: Config.fontFamily
        font.pixelSize: 12
        verticalAlignment: Text.AlignVCenter
    }
}
