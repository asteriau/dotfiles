import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.utils

DialogListItem {
    id: row
    required property var modelData
    required property bool isDefault
    signal selected(var node)

    readonly property var node: modelData
    readonly property string label: {
        if (!node) return "Unknown";
        return node.description || node.nickname || node.name || "Unknown";
    }

    active: row.isDefault
    contentHeight: layout.implicitHeight + row.verticalPadding * 2
    onClicked: row.selected(row.node)

    RowLayout {
        id: layout
        anchors {
            fill: parent
            topMargin: row.verticalPadding
            bottomMargin: row.verticalPadding
            leftMargin: row.horizontalPadding
            rightMargin: row.horizontalPadding
        }
        spacing: 10

        Text {
            text: row.isDefault ? "radio_button_checked" : "radio_button_unchecked"
            color: row.isDefault ? Appearance.colors.colPrimary : Appearance.colors.m3onSurfaceVariant
            font.family: Appearance.typography.iconFamily
            font.pixelSize: Appearance.typography.larger
        }

        Text {
            Layout.fillWidth: true
            text: row.label
            color: Appearance.colors.m3onSurfaceVariant
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.small
            font.weight: row.isDefault ? Appearance.typography.weightMedium : Appearance.typography.weightNormal
            elide: Text.ElideRight
        }
    }
}
