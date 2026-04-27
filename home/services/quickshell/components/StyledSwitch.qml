import QtQuick
import qs.utils

// Material 3 expressive switch.
Item {
    id: root
    implicitWidth: 52
    implicitHeight: 32

    property bool checked: false
    signal toggled(bool value)

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Colors.accent : Colors.surfaceContainerHighest
        border.width: root.checked ? 0 : 2
        border.color: Colors.m3outline

        Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }

        Rectangle {
            id: thumb
            property real targetSize: root.checked ? 28 : 24
            width: ma.pressed ? 30 : targetSize
            height: width
            radius: width / 2
            color: root.checked ? Colors.m3onPrimary : Colors.m3onSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 2 : 2

            Behavior on x { SpringAnimation { spring: 4; damping: 0.6; mass: 0.6 } }
            Behavior on width { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
