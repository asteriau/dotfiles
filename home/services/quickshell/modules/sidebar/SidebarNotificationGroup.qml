pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.notifications
import qs.services

Item {
    id: root

    required property var notificationGroup
    required property bool expanded
    required property int index
    property var notifications: notificationGroup?.notifications ?? []
    property int notificationCount: notifications.reduce((total, notif) =>
        total + (notif.count ?? 1), 0)
    property bool multipleNotifications: notificationCount > 1
    property real dragThreshold: 70
    property real xOffset: 0

    implicitHeight: background.implicitHeight

    function toggleExpanded() {
        root.expanded = !root.expanded;
    }

    Rectangle {
        id: background
        width: parent.width
        x: root.xOffset
        radius: Appearance.layout.radiusMd
        color: Appearance.colors.colLayer2
        clip: true
        implicitHeight: row.implicitHeight + 20

        Behavior on x {
            NumberAnimation {
                duration: Appearance.motion.duration.medium1
                easing.type: Easing.OutCubic
            }
        }
        Behavior on implicitHeight {
            NumberAnimation {
                duration: Appearance.motion.duration.medium2
                easing.type: Easing.OutCubic
            }
        }

        RowLayout {
            id: row
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 10

            NotificationAppIcon {
                Layout.alignment: Qt.AlignTop
                implicitSize: 38
                image: root.multipleNotifications ? "" : root.notifications[0]?.image ?? ""
                appIcon: root.notificationGroup?.appIcon ?? ""
                summary: root.notifications[root.notifications.length - 1]?.summary ?? ""
                urgency: root.notifications.some(n => n.urgency === NotificationUrgency.Critical) ?
                    NotificationUrgency.Critical : NotificationUrgency.Normal
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: root.expanded ? 5 : 0

                Item {
                    Layout.fillWidth: true
                    implicitHeight: Math.max(groupTitle.implicitHeight, expandButton.implicitHeight)

                    StyledText {
                        id: groupTitle
                        anchors.left: parent.left
                        anchors.right: timeText.left
                        anchors.rightMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        text: root.multipleNotifications
                            ? (root.notificationGroup?.appName ?? "Notification")
                            : (root.notifications[0]?.summary ?? "")
                        color: root.multipleNotifications
                            ? Appearance.colors.comment
                            : Appearance.colors.foreground
                        font.pixelSize: root.multipleNotifications
                            ? Appearance.typography.smallie
                            : Appearance.typography.small
                        font.weight: root.multipleNotifications ? Font.Normal : Font.DemiBold
                    }

                    StyledText {
                        id: timeText
                        anchors.right: expandButton.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: NotificationUtils.getFriendlyNotifTimeString(root.notificationGroup?.time)
                        color: Appearance.colors.comment
                        font.pixelSize: Appearance.typography.smallie
                    }

                    Rectangle {
                        id: expandButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        implicitWidth: Math.max(30, expandRow.implicitWidth + 10)
                        implicitHeight: Appearance.typography.smallie + 8
                        width: implicitWidth
                        height: implicitHeight
                        radius: height / 2
                        color: expandMouse.pressed ? Appearance.colors.pressedStrong
                             : expandMouse.containsMouse ? Appearance.colors.hoverStrongest
                             : ColorUtils.mix(Appearance.colors.colLayer2,
                                              Appearance.colors.colLayer2Hover, 0.5)

                        RowLayout {
                            id: expandRow
                            anchors.centerIn: parent
                            spacing: 3

                            StyledText {
                                visible: root.notificationCount > 1
                                Layout.leftMargin: 4
                                Layout.alignment: Qt.AlignVCenter
                                text: root.notificationCount
                                font.pixelSize: Appearance.typography.smallie
                                color: Appearance.colors.colOnLayer2
                            }
                            MaterialIcon {
                                Layout.alignment: Qt.AlignVCenter
                                text: "keyboard_arrow_down"
                                pixelSize: Appearance.typography.normal
                                color: Appearance.colors.colOnLayer2
                                rotation: root.expanded ? 180 : 0
                                Behavior on rotation {
                                    NumberAnimation { duration: Appearance.motion.duration.medium1 }
                                }
                            }
                        }

                        MouseArea {
                            id: expandMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.toggleExpanded()
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: root.expanded ? 5 : 3

                    Repeater {
                        model: root.notifications
                        delegate: SidebarNotificationItem {
                            required property int index
                            required property var modelData
                            Layout.fillWidth: true
                            notificationRef: modelData
                            onlyNotification: root.notifications.length === 1
                            expanded: root.expanded
                            visible: root.expanded || index < 2
                            opacity: !root.expanded && index === 1 && root.notifications.length > 2 ? 0.5 : 1
                        }
                    }
                }
            }
        }

        NotificationDragHandler {
            target: background
            enabled: !root.expanded
            onDismissRequested: {
                root.notifications.forEach(n => Notifications.notifCloseByNotif(n));
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton | Qt.MiddleButton
            onClicked: event => {
                if (event.button === Qt.RightButton)
                    root.toggleExpanded();
                else
                    root.notifications.forEach(n => Notifications.notifCloseByNotif(n));
            }
        }
    }
}
