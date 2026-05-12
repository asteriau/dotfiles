import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

ColumnLayout {
    id: root
    property string title: ""
    property string tooltip: ""
    default property alias contentData: sectionContent.data

    Layout.fillWidth: true
    Layout.topMargin: 4
    spacing: 4

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 16
        Layout.rightMargin: 16
        Layout.topMargin: 10
        Layout.bottomMargin: 4
        visible: root.title.length > 0 || root.tooltip.length > 0
        spacing: Appearance.layout.rowGap

        Text {
            visible: root.title.length > 0
            text: root.title
            color: Appearance.colors.m3onSurfaceVariant
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.smaller
            font.weight: Font.Medium
        }

        HoverTooltip {
            visible: root.tooltip.length > 0
            text: root.tooltip
            MaterialIcon {
                text: "info"
                font.pointSize: Appearance.typography.smaller
                color: Appearance.colors.comment
            }
        }

        Item { Layout.fillWidth: true }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        Layout.bottomMargin: 4
        spacing: Appearance.layout.subsectionGap
    }
}
