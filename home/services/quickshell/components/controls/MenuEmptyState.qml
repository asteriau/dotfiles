import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

// Centered placeholder shown when a context-menu list is empty or disabled.
// Stack: large material icon, title, optional caption.
ColumnLayout {
    id: root

    property string iconName: ""
    property string title: ""
    property string detail: ""

    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    spacing: Config.layout.gapSm

    Text {
        Layout.alignment: Qt.AlignHCenter
        visible: root.iconName.length > 0
        text: root.iconName
        color: Colors.m3onSurfaceInactive
        font.family: Config.typography.iconFamily
        font.pixelSize: 32
    }

    StyledText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        variant: StyledText.Variant.BodySm
        color: Colors.m3onSurface
        text: root.title
        elide: Text.ElideRight
    }

    StyledText {
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        visible: root.detail.length > 0
        variant: StyledText.Variant.Caption
        color: Colors.m3onSurfaceInactive
        text: root.detail
        elide: Text.ElideRight
    }
}
