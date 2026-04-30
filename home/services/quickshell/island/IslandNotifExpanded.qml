pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.notifications
import qs.utils

// Expanded notif card: large app icon + (appName / summary / body).
Item {
    id: root

    property var notif: null

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        NotificationAppIcon {
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 2
            implicitSize: 48
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            image:    root.notif?.image ?? ""
            appIcon:  root.notif?.appIcon ?? ""
            summary:  root.notif?.summary ?? ""
            urgency:  root.notif?.urgency ?? 0
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2

            StyledText {
                Layout.fillWidth: true
                visible: text.length > 0
                variant: StyledText.Variant.Label
                text: root.notif?.appName ?? ""
                elide: Text.ElideRight
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
