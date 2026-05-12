import QtQuick
import qs.modules.common.widgets
import qs.modules.common

Row {
    id: root

    required property string icon
    required property int percentage

    spacing: 1

    MaterialIcon {
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        fill: 1
        pixelSize: 11
        weight: Font.DemiBold
        color: "white"
    }
    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: `${root.percentage}`
        font.family: Config.typography.family
        font.pixelSize: Appearance.typography.smallie
        font.weight: root.percentage < 100 ? Font.DemiBold : Font.Medium
        color: "white"
    }
}
