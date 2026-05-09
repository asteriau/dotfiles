import QtQuick
import QtQuick.Layouts
import qs.utils

Item {
    id: row
    required property var modelData
    required property bool isDefault
    signal selected(var node)

    Layout.fillWidth: true
    implicitHeight: 40

    readonly property var node: modelData
    readonly property string label: {
        if (!node) return "Unknown";
        return node.nickname || node.description || node.name || "Unknown";
    }

    Rectangle {
        anchors.fill: parent
        radius: Config.layout.radiusSm
        color: rowMa.containsMouse ? Colors.colLayer3 : "transparent"
        Behavior on color { Motion.ColorFade {} }
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 10
            rightMargin: 10
        }
        spacing: 10

        Text {
            text: row.isDefault ? "radio_button_checked" : "radio_button_unchecked"
            color: row.isDefault ? Colors.colPrimary : Colors.m3onSurfaceVariant
            font.family: "Material Symbols Rounded"
            font.pixelSize: 18
        }

        Text {
            Layout.fillWidth: true
            text: row.label
            color: Colors.m3onSurface
            font.family: "Inter"
            font.pixelSize: 13
            font.weight: row.isDefault ? Font.Medium : Font.Normal
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: rowMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.selected(row.node)
    }
}
