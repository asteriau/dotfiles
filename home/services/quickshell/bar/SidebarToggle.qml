import QtQuick
import Qt5Compat.GraphicalEffects
import qs.components.surfaces
import qs.utils
import qs.utils.state

PressablePill {
    id: root

    radius: width / 2
    colorIdle:    Colors.transparent
    colorHover:   Colors.hoverStrong
    colorPressed: Colors.hoverStrong
    pressScale: 0.9
    pressDuration: M3Easing.durationShort3  // match sparkIcon's scale timing

    implicitWidth: 32
    implicitHeight: 32

    readonly property color iconColor: Colors.accent

    Image {
        id: sparkIcon
        anchors.centerIn: parent
        source: Qt.resolvedUrl("../assets/spark-symbolic.svg")
        width: 19
        height: 19
        sourceSize: Qt.size(width, height)
        scale: root.pressed ? 0.9 : 1.0

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

    onClicked: {
        NotificationState.notifOverlayOpen = false;
        Config.showSidebar = !Config.showSidebar;
    }
}
