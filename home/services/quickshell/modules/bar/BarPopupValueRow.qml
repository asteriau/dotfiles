import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

RowLayout {
    id: root
    required property string icon
    required property string label
    required property string value
    spacing: Appearance.layout.gapSm
    // Stretch to the parent column so AlignRight on the value works.
    Layout.fillWidth: true

    MaterialIcon {
        Layout.alignment: Qt.AlignVCenter
        text: root.icon
        pixelSize: Appearance.typography.normal
        color: Appearance.colors.m3onSurfaceVariant
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: root.label
        font.family: Config.typography.family
        font.pixelSize: Appearance.typography.normal
        color: Appearance.colors.m3onSurfaceVariant
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        text: root.value
        font.family: Config.typography.family
        font.pixelSize: Appearance.typography.normal
        font.weight: Font.Medium
        color: Appearance.colors.m3onSurfaceVariant
    }
}
