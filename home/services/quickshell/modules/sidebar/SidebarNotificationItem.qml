import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.notifications
import qs.services

Item {
    id: root

    required property var notificationRef
    property bool expanded: false
    property bool onlyNotification: false

    implicitHeight: background.implicitHeight

    Rectangle {
        id: background
        width: parent.width
        radius: Appearance.layout.radiusSm
        color: root.expanded && !root.onlyNotification
            ? (root.notificationRef?.urgency === 2
                ? Appearance.colors.errorContainer
                : Appearance.colors.colLayer3)
            : Appearance.colors.transparent
        implicitHeight: content.implicitHeight + (root.expanded ? 16 : 0)

        Behavior on implicitHeight {
            NumberAnimation {
                duration: Appearance.motion.duration.effects
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: root.expanded ? 8 : 0
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                visible: !root.onlyNotification || !root.expanded
                spacing: 5

                StyledText {
                    visible: !root.onlyNotification
                    Layout.fillWidth: true
                    text: root.notificationRef?.summary ?? ""
                    color: Appearance.colors.colOnLayer3
                    font.pixelSize: Appearance.typography.small
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.notificationRef?.body ?? ""
                    color: Appearance.colors.comment
                    font.pixelSize: Appearance.typography.small
                    textFormat: Text.StyledText
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            NotificationBody {
                notificationRef: root.notificationRef
                expanded: true
                visible: root.expanded
            }

            NotificationActions {
                notificationRef: root.notificationRef
                progress: root.expanded ? 1 : 0
                visible: root.expanded
                onDismiss: Notifications.notifCloseByNotif(root.notificationRef)
            }
        }
    }
}
