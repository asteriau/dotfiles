import QtQuick
import QtQuick.Layouts
import qs.components.effects
import qs.components.text
import qs.utils

ColumnLayout {
    id: root
    property string title: ""
    property string tooltip: ""
    default property alias contentData: sectionContent.data

    Layout.fillWidth: true
    Layout.topMargin: Config.layout.rowGap
    spacing: Config.layout.subsectionGap

    RowLayout {
        Layout.fillWidth: true
        visible: root.title.length > 0 || root.tooltip.length > 0
        spacing: Config.layout.rowGap

        Text {
            visible: root.title.length > 0
            text: root.title
            color: Colors.comment
            font.family: Config.typography.family
            font.pixelSize: Config.typography.smallie
            Layout.leftMargin: 2
        }

        HoverTooltip {
            visible: root.tooltip.length > 0
            text: root.tooltip
            MaterialIcon {
                text: "info"
                font.pointSize: Config.typography.smaller
                color: Colors.comment
            }
        }

        Item { Layout.fillWidth: true }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        spacing: Config.layout.subsectionGap
    }
}
