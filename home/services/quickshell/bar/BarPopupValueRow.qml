import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

RowLayout {
    id: root
    required property string icon
    required property string label
    required property string value
    spacing: 4
    // Stretch to the parent column so AlignRight on the value works.
    Layout.fillWidth: true

    MaterialIcon {
        Layout.alignment: Qt.AlignVCenter
        text: root.icon
        pixelSize: Config.typography.normal
        color: Colors.m3onSurfaceVariant
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        text: root.label
        font.family: Config.fontFamily
        font.pixelSize: Config.typography.normal
        color: Colors.m3onSurfaceVariant
    }

    Text {
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        text: root.value
        font.family: Config.fontFamily
        font.pixelSize: Config.typography.normal
        font.weight: Font.Medium
        color: Colors.m3onSurfaceVariant
    }
}
