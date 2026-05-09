import QtQuick
import QtQuick.Layouts
import qs.utils

// Indeterminate progress bar for dialog scan / loading states.
// Active: animates a primary-colored pill across the track.
// Idle: renders a hairline divider in the same slot.
Item {
    id: root

    property bool active: false

    Layout.fillWidth: true
    implicitHeight: 4

    Rectangle {
        id: track
        anchors.fill: parent
        radius: 2
        color: Colors.colSecondaryContainer
        opacity: root.active ? 0.6 : 0.4
        clip: true
        Behavior on opacity { Motion.Fade {} }

        Rectangle {
            visible: root.active
            width: parent.width * 0.3
            height: parent.height
            radius: parent.radius
            color: Colors.colPrimary

            NumberAnimation on x {
                running: root.active && root.visible
                loops: Animation.Infinite
                from: -width
                to: track.width
                duration: 1100
            }
        }
    }
}
