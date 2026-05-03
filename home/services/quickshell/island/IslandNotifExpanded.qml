pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.notifications
import qs.utils
import qs.utils.state

Item {
    id: root

    property var notif: null

    property string timeString: NotificationUtils.getFriendlyNotifTimeString(notif?.time)

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.timeString = NotificationUtils.getFriendlyNotifTimeString(root.notif?.time)
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        NotificationAppIcon {
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 2
            implicitSize: 38
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            image:    root.notif?.image ?? ""
            appIcon:  root.notif?.appIcon ?? ""
            summary:  root.notif?.summary ?? ""
            urgency:  root.notif?.urgency ?? 0
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    variant: StyledText.Variant.Label
                    text: root.notif?.appName ?? ""
                    elide: Text.ElideRight
                }

                StyledText {
                    visible: root.timeString.length > 0
                    variant: StyledText.Variant.Caption
                    text: root.timeString
                    horizontalAlignment: Text.AlignRight
                }
            }

            StyledText {
                Layout.fillWidth: true
                variant: StyledText.Variant.Subtitle
                text: root.notif?.summary ?? ""
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            StyledText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: text.length > 0
                variant: StyledText.Variant.BodySm
                text: root.notif?.body ?? ""
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                maximumLineCount: 2
            }
        }
    }
}
