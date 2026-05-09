import QtQuick
import QtQuick.Layouts
import qs.utils

// Sliding-pill indeterminate progress bar used by Wi-Fi / Bluetooth scan.
// When `active` is false, collapses to a static hairline.
Item {
    id: root

    property bool active: false

    Layout.fillWidth: true
    implicitHeight: 2

    Rectangle {
        id: track
        anchors.fill: parent
        radius: 1
        color: Colors.outlineVariant
        opacity: root.active ? 0.3 : 0.4
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
