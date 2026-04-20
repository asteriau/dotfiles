import QtQuick
import qs.components
import qs.utils

Item {
    id: root

    implicitWidth: 32
    implicitHeight: 32

    readonly property color iconColor: "#8DA3B9"

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: width / 2
        color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        scale: ma.pressed ? 0.9 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
    }

    MaterialIcon {
        anchors.centerIn: parent
        text: "dark_mode"
        fill: 1
        font.pixelSize: 22
        font.weight: Font.Medium
        color: root.iconColor
        scale: ma.pressed ? 0.9 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            NotificationState.notifOverlayOpen = false;
            Config.showSidebar = !Config.showSidebar;
        }
    }
}
