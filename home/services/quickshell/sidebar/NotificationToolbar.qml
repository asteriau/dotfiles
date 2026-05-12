import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.components.text
import qs.sidebar.controls
import qs.utils
import qs.services

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 8

    readonly property int notifCount: NotificationState.allNotifs.length

    StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: root.notifCount > 0
            ? (root.notifCount + " notification" + (root.notifCount === 1 ? "" : "s"))
            : "No notifications"
        color: root.notifCount > 0 ? Colors.foreground : Colors.comment
        font.pixelSize: Config.typography.smallie
        font.weight: Font.Medium

        Behavior on color {
            ColorAnimation { duration: Appearance.motion.duration.effects }
        }
    }

    PillToggle {
        icon: "delete_sweep"
        active: root.notifCount > 0
        onClicked: NotificationState.closeAll()
    }
}
