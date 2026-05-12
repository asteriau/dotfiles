import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.modules.common.widgets
import qs.modules.sidebar.controls
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: Appearance.layout.gapMd

    readonly property int notifCount: Notifications.allNotifs.length

    StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.layout.gapMd
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: root.notifCount > 0
            ? (root.notifCount + " notification" + (root.notifCount === 1 ? "" : "s"))
            : "No notifications"
        color: root.notifCount > 0 ? Appearance.colors.foreground : Appearance.colors.comment
        font.pixelSize: Appearance.typography.smallie
        font.weight: Font.Medium

        Behavior on color {
            ColorAnimation { duration: Appearance.motion.duration.effects }
        }
    }

    PillToggle {
        icon: "delete_sweep"
        active: root.notifCount > 0
        onClicked: Notifications.closeAll()
    }
}
