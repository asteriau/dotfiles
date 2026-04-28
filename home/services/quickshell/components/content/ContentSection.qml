import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

ColumnLayout {
    id: root

    property string title
    property string icon: ""

    default property alias contentData: sectionContent.data

    Layout.fillWidth: true
    spacing: 6

    RowLayout {
        Layout.fillWidth: true
        visible: root.title.length > 0 || root.icon.length > 0
        spacing: Config.layout.rowSpacing

        MaterialIcon {
            visible: root.icon.length > 0
            text: root.icon
            font.pointSize: Config.typography.hugeass
            fill: 1
            color: Colors.accent
        }

        Text {
            text: root.title
            color: Colors.foreground
            font.family: Config.typography.titleFamily
            font.pixelSize: Config.typography.larger
            font.weight: Font.Medium
        }

        Item { Layout.fillWidth: true }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        spacing: Config.layout.sectionInner
    }
}
