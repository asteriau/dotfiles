import QtQuick
import Qt5Compat.GraphicalEffects
import qs.components.surfaces
import qs.utils
import qs.services

PressablePill {
    id: root

    radius: width / 2
    colorIdle:    Colors.transparent
    useStateLayer: true
    stateLayerTone: iconColor
    pressScale: 0.9
    pressDuration: Appearance.motion.duration.short3  // match sparkIcon's scale timing

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
                duration: Appearance.motion.duration.short3
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
        UiState.showSidebar = !UiState.showSidebar;
    }
}
