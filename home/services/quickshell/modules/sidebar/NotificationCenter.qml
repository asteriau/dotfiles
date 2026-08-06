pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.services

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: 180
    radius: Appearance.layout.radiusLg
    color: Appearance.colors.colLayer1
    antialiasing: true
    clip: true

    NotificationToolbar {
        id: toolbar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 5
    }

    ListView {
        id: list
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: toolbar.top
        anchors.margins: 5
        anchors.bottomMargin: 10
        clip: true
        spacing: 3
        interactive: true
        boundsBehavior: Flickable.DragOverBounds
        model: ScriptModel {
            values: Notifications.appNameList
        }
        delegate: Item {
            required property int index
            required property var modelData
            width: ListView.view.width
            implicitHeight: group.implicitHeight

            SidebarNotificationGroup {
                id: group
                anchors.left: parent.left
                anchors.right: parent.right
                notificationGroup: Notifications.groupsByAppName[modelData]
                expanded: false
                index: parent.index
            }
        }
    }

    Item {
        anchors.fill: list
        visible: Notifications.allNotifs.length === 0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 5

            MaterialShape {
                Layout.alignment: Qt.AlignHCenter
                shape: MaterialShape.Shape.Ghostish
                color: Appearance.colors.colLayer2
                implicitSize: 80

                MaterialIcon {
                    anchors.centerIn: parent
                    text: "notifications_active"
                    pixelSize: 40
                    color: Appearance.colors.comment
                }
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: "Nothing"
                color: Appearance.colors.comment
                font.pixelSize: Appearance.typography.small
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
