import QtQuick
import qs.modules.common

CircularProgress {
    id: root

    required property string icon
    required property real value

    implicitSize: 20
    lineWidth: 2
    color: Appearance.colors.m3onSecondaryContainer
    enableAnimation: true

    Item {
        anchors.centerIn: parent
        width: 20
        height: 20

        MaterialIcon {
            anchors.centerIn: parent
            text: root.icon
            pixelSize: Appearance.typography.normal
            color: Appearance.colors.m3onSecondaryContainer
        }
    }
}
