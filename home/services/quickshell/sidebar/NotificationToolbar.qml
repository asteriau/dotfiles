import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.utils

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    Rectangle {
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: 14
        color: Config.doNotDisturb ? Colors.accent : Colors.elevated
        antialiasing: true

        Behavior on color {
            ColorAnimation { duration: M3Easing.effectsDuration }
        }

        Text {
            anchors.centerIn: parent
            text: Config.doNotDisturb ? "notifications_off" : "notifications_paused"
            font.family: "Material Symbols Rounded"
            font.pixelSize: 18
            color: Config.doNotDisturb ? Colors.elevated : Colors.accent
            renderType: Text.NativeRendering
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Config.doNotDisturb = !Config.doNotDisturb
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 44
        radius: 14
        color: Colors.elevated
        antialiasing: true

        Text {
            anchors.centerIn: parent
            text: NotificationState.allNotifs.length > 0 ? (NotificationState.allNotifs.length + " notification" + (NotificationState.allNotifs.length === 1 ? "" : "s")) : "No notifications"
            color: Colors.comment
            font.family: Config.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }

    Rectangle {
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: 14
        color: Colors.elevated
        antialiasing: true

        Behavior on color {
            ColorAnimation { duration: M3Easing.effectsDuration }
        }

        Text {
            anchors.centerIn: parent
            text: "delete_sweep"
            font.family: "Material Symbols Rounded"
            font.pixelSize: 18
            color: Colors.accent
            renderType: Text.NativeRendering
        }

        MouseArea {
            id: clearMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: NotificationState.closeAll()
        }
    }
}
