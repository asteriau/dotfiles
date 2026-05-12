import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property bool active: false

    Layout.fillWidth: true
    implicitHeight: 4
    visible: active

    Rectangle {
        id: track
        anchors.fill: parent
        radius: 2
        color: Appearance.colors.colSecondaryContainer
        opacity: 0.6
        clip: true

        Rectangle {
            visible: root.active
            width: parent.width * 0.3
            height: parent.height
            radius: parent.radius
            color: Appearance.colors.colPrimary

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
