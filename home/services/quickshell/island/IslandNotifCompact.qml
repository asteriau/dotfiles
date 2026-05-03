pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.notifications
import qs.utils

Item {
    id: root

    property var notif: null

    readonly property bool isCritical: (notif?.urgency ?? 0) === 2

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 14
        spacing: 10

        NotificationAppIcon {
            Layout.alignment: Qt.AlignVCenter
            implicitSize: 28
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            image:    root.notif?.image ?? ""
            appIcon:  root.notif?.appIcon ?? ""
            summary:  root.notif?.summary ?? ""
            urgency:  root.notif?.urgency ?? 0
        }

        StyledText {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            variant: StyledText.Variant.Body
            elide: Text.ElideRight
            color: root.isCritical ? Colors.red : Colors.foreground
            font.weight: Font.DemiBold
            text: root.notif?.summary ?? ""
        }
    }
}
