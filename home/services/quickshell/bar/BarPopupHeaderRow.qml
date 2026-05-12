import QtQuick
import qs.components.text
import qs.utils

Row {
    id: root
    required property string icon
    required property string label
    spacing: 5

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        pixelSize: Config.typography.large
        weight: Font.DemiBold
        color: Appearance.colors.m3onSurfaceVariant
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        font.family: Config.fontFamily
        font.pixelSize: Config.typography.normal
        font.weight: Font.DemiBold
        color: Appearance.colors.m3onSurfaceVariant
    }
}
