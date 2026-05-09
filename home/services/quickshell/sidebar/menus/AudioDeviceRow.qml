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
            color: row.isDefault ? Colors.colPrimary : Colors.m3onSurfaceVariant
            font.family: Config.typography.iconFamily
            font.pixelSize: Config.typography.larger
        }

        Text {
            Layout.fillWidth: true
            text: row.label
            color: Colors.m3onSurfaceVariant
            font.family: Config.typography.family
            font.pixelSize: Config.typography.small
            font.weight: row.isDefault ? Config.typography.weightMedium : Config.typography.weightNormal
            elide: Text.ElideRight
        }
    }
}
