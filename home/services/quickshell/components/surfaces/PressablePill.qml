import QtQuick
import qs.utils

// Rounded pressable surface. Generic base for pills, tiles, chips, icon buttons.
// Exposes `hovered`/`pressed` states; children can bind to them.
//
// Defaults are no-op on hover (matches existing PillToggle/TileSmall behavior).
// Opt in to hover tinting by overriding `colorHover`.
Item {
    id: root

    property real radius: Config.layout.radiusXl
    property color colorIdle:    Colors.elevated
    property color colorHover:   colorIdle           // no-op by default
    property color colorPressed: colorIdle           // no-op by default
    property color colorActive:  Colors.accent
    property color colorActiveHover: Colors.accentHover

    property bool active: false
    property bool enableScale: true
    property real pressScale: 0.92
    property int  pressDuration: M3Easing.pressDuration

    readonly property alias hovered: ma.containsMouse
    readonly property alias pressed: ma.pressed

    default property alias data: contentItem.data

    signal clicked
    signal rightClicked

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: root.radius
        antialiasing: true
        color: root.active
            ? (ma.containsMouse ? root.colorActiveHover : root.colorActive)
            : (ma.pressed ? root.colorPressed : ma.containsMouse ? root.colorHover : root.colorIdle)
        scale: root.enableScale && ma.pressed ? root.pressScale : 1.0

        Behavior on color {
            ColorAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: root.pressDuration; easing.type: Easing.OutQuad }
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
