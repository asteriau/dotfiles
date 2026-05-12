// Body text of a notification. Two-line preview when collapsed, rich-text
// processed body when expanded.
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils
import qs.services

StyledText {
    id: root

    property var notificationRef: null
    property bool expanded: false

    readonly property string rawBody: notificationRef?.body ?? ""
    readonly property string appName: notificationRef?.appName ?? ""

    Layout.fillWidth: true
    text: expanded ? NotificationUtils.processNotificationBody(rawBody, appName) : rawBody
    color: Appearance.colors.comment
    font.pixelSize: Appearance.typography.smallie
    wrapMode: Text.Wrap
    elide: Text.ElideRight
    maximumLineCount: expanded ? 100 : 2
    textFormat: expanded ? Text.RichText : Text.PlainText
    verticalAlignment: Text.AlignTop
    visible: text.length > 0
}
