import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property real radius: Appearance.layout.radiusXl
    property real topLeftRadius:     -1
    property real topRightRadius:    -1
    property real bottomLeftRadius:  -1
    property real bottomRightRadius: -1
    property color colorIdle:    Appearance.colors.elevated
    property color colorHover:   colorIdle           // no-op by default
    property color colorPressed: colorIdle           // no-op by default
    property color colorActive:  Appearance.colors.accent
    property color colorActiveHover: Appearance.colors.accentHover

    property bool active: false
    property bool enableScale: true
    property real pressScale: 0.92
    property int  pressDuration: Appearance.motion.duration.press

    // MD3 state-layer overlay (opt-in). When true, hover/press color blending is
    // suppressed and a StateLayer overlay handles visual feedback.
    property bool useStateLayer: false
    property color stateLayerTone: Appearance.colors.m3onSurface

    readonly property alias hovered: ma.containsMouse
    readonly property alias pressed: ma.pressed

    default property alias data: contentItem.data

    signal clicked
    signal rightClicked

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.radius
        topLeftRadius:     root.topLeftRadius     >= 0 ? root.topLeftRadius     : root.radius
        topRightRadius:    root.topRightRadius    >= 0 ? root.topRightRadius    : root.radius
        bottomLeftRadius:  root.bottomLeftRadius  >= 0 ? root.bottomLeftRadius  : root.radius
        bottomRightRadius: root.bottomRightRadius >= 0 ? root.bottomRightRadius : root.radius
        antialiasing: true
        color: root.useStateLayer
            ? (root.active ? root.colorActive : root.colorIdle)
            : root.active
                ? (ma.containsMouse ? root.colorActiveHover : root.colorActive)
                : (ma.pressed ? root.colorPressed : ma.containsMouse ? root.colorHover : root.colorIdle)
        scale: root.enableScale && ma.pressed ? root.pressScale : 1.0

        Behavior on color {
            ColorAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: root.pressDuration; easing.type: Easing.OutQuad }
        }

        StateLayer {
            anchors.fill: parent
            visible: root.useStateLayer
            radius: root.radius
            topLeftRadius:     root.topLeftRadius
            topRightRadius:    root.topRightRadius
            bottomLeftRadius:  root.bottomLeftRadius
            bottomRightRadius: root.bottomRightRadius
            tone: root.stateLayerTone
            hovered: ma.containsMouse
            pressed: ma.pressed
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: ev => {
            if (ev.button === Qt.RightButton) root.rightClicked();
            else root.clicked();
        }
    }
}
