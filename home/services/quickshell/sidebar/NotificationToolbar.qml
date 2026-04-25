import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.sidebar.quickToggles
import qs.utils

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 8

    readonly property int notifCount: NotificationState.allNotifs.length

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: root.notifCount > 0
            ? (root.notifCount + " notification" + (root.notifCount === 1 ? "" : "s"))
            : "No notifications"
        color: root.notifCount > 0 ? Colors.m3onSurfaceVariant : Colors.m3outline
        font.family: Config.fontFamily
        font.pixelSize: 13
        font.weight: Font.Medium

        Behavior on color {
            ColorAnimation { duration: M3Easing.effectsDuration }
        }
    }

    PillToggle {
        icon: "delete_sweep"
        active: root.notifCount > 0
        onClicked: NotificationState.closeAll()
    }
}
