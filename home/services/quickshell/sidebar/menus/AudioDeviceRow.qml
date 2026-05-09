import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.utils

MenuRow {
    id: row
    required property var modelData
    required property bool isDefault
    signal selected(var node)

    readonly property var node: modelData
    readonly property string label: {
        if (!node) return "Unknown";
        return node.nickname || node.description || node.name || "Unknown";
    }

    iconName: isDefault ? "radio_button_checked" : "radio_button_unchecked"
    iconColor: isDefault ? Colors.colPrimary : Colors.m3onSurfaceVariant
    iconSize: 18
    primaryText: row.label
    active: row.isDefault

    onClicked: row.selected(row.node)
}
