import QtQuick
import qs.modules.common.widgets
import qs.modules.common

Column {
    id: root

    required property string icon
    required property int percentage

    spacing: -4

    MaterialIcon {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.icon
        fill: 1
        pixelSize: Appearance.typography.normal
        weight: Font.DemiBold
        color: "white"
    }
    Text {
        visible: root.percentage < 100
        anchors.horizontalCenter: parent.horizontalCenter
        text: `${root.percentage}`
        font.family: Config.typography.family
        font.pixelSize: Appearance.typography.smallie
        font.weight: Font.DemiBold
        color: "white"
    }
}
