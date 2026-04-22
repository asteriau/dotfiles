import QtQuick
import Qt5Compat.GraphicalEffects
import qs.components
import qs.utils

Item {
    id: root

    implicitWidth: 32
    implicitHeight: 32

    readonly property color iconColor: Colors.accent

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: width / 2
        color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
        scale: ma.pressed ? 0.9 : 1.0

        Behavior on color {
            ColorAnimation {
                duration: M3Easing.effectsDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: M3Easing.durationShort3
                easing.type: Easing.OutQuad
            }
        }
    }

    Image {
        id: sparkIcon
        anchors.centerIn: parent
        source: Qt.resolvedUrl("../assets/spark-symbolic.svg")
        width: 19
        height: 19
        sourceSize: Qt.size(width, height)
        scale: ma.pressed ? 0.9 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: M3Easing.durationShort3
                easing.type: Easing.OutQuad
            }
        }
    }

    ColorOverlay {
        anchors.fill: sparkIcon
        source: sparkIcon
        color: root.iconColor
        scale: sparkIcon.scale
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
