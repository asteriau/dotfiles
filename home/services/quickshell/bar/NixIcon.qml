import QtQuick
import QtQuick.Effects
import qs.utils

Item {
    id: root

    implicitWidth: 28
    implicitHeight: 28

    Image {
        id: icon
        anchors.centerIn: parent
        width: 25
        height: 25
        source: Qt.resolvedUrl("../assets/nixos.png")
        sourceSize.width: 50
        sourceSize.height: 50
        smooth: true
        mipmap: true
    }

    MultiEffect {
        source: icon
        anchors.fill: icon
        shadowEnabled: Config.shadowEnabled
        shadowVerticalOffset: Config.shadowVerticalOffset
        blurMax: Config.blurMax
        opacity: Config.shadowOpacity
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
        }
    }
}
