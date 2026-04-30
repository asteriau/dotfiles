pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.notifications
import qs.utils

// Compact notif row: small app icon + summary.
Item {
    id: root

    property var notif: null

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 14
        spacing: 10

        NotificationAppIcon {
            Layout.alignment: Qt.AlignVCenter
            implicitSize: 22
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
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
            color: Colors.foreground
            font.weight: Font.Medium
            text: {
                const n = root.notif;
                if (!n) return "";
                const s = n.summary ?? "";
                const b = n.body ?? "";
                return s && b ? `${s} — ${b}` : (s || b);
            }
        }
    }
}
