import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Item {
    id: root
    implicitHeight: 36

    readonly property int notifCount: Notifications.allNotifs.length

    RowLayout {
        anchors.fill: parent
        spacing: 5

        StatusButton {
            Layout.preferredWidth: 82
            icon: "notifications_paused"
            toggled: Notifications.silent
            onClicked: Notifications.silent = !Notifications.silent
        }

        StatusButton {
            Layout.fillWidth: true
            enabled: false
            label: root.notifCount + " notification" + (root.notifCount === 1 ? "" : "s")
        }

        StatusButton {
            Layout.preferredWidth: 82
            icon: "delete_sweep"
            enabled: root.notifCount > 0
            onClicked: Notifications.closeAll()
        }
    }

    component StatusButton: Rectangle {
        id: button
        property string icon: ""
        property string label: ""
        property bool toggled: false
        signal clicked

        Layout.fillHeight: true
        radius: mouse.pressed ? Appearance.layout.radiusSm : height / 2
        color: !enabled ? Appearance.colors.colLayer2
             : toggled ? Appearance.colors.colPrimary
             : mouse.pressed ? Appearance.colors.colLayer2Active
             : mouse.containsMouse ? Appearance.colors.colLayer2Hover
             : Appearance.colors.colLayer2
        opacity: enabled ? 1 : 0.8

        Behavior on radius {
            NumberAnimation { duration: Appearance.motion.duration.medium1 }
        }
        Behavior on color {
            ColorAnimation { duration: Appearance.motion.duration.effects }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 5

            MaterialIcon {
                visible: button.icon !== ""
                text: button.icon
                pixelSize: Appearance.typography.large
                color: button.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer1
            }
            StyledText {
                visible: button.label !== ""
                text: button.label
                font.pixelSize: Appearance.typography.small
                color: button.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer1
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            enabled: button.enabled
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: button.clicked()
        }
    }
}
