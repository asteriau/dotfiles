import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

ColumnLayout {
    id: root

    property string title

    default property alias contentData: sectionContent.data

    Layout.fillWidth: true
    spacing: 12

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.bottomMargin: 2
        visible: root.title.length > 0
        spacing: 6

        Text {
            text: root.title
            color: Colors.m3onSurfaceVariant
            font.family: Config.typography.titleFamily
            font.pixelSize: Config.typography.small
            font.weight: Font.Medium
        }

        Item { Layout.fillWidth: true }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: sectionContent.implicitHeight + Config.layout.gapLg
        color: Colors.colLayer2
        radius: 20
        clip: true

        ColumnLayout {
            id: sectionContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 6
            spacing: 0
        }

        Repeater {
            model: sectionContent.children.length
            Rectangle {
                required property int index
                readonly property var child: sectionContent.children[index]
                visible: index > 0 && child !== null && child.y > 0
                x: 16
                Binding on y {
                    value: sectionContent.y + (child ? child.y : 0)
                    delayed: true
                }
                width: sectionContent.width - 32
                height: 1
                color: Colors.outlineVariant
                opacity: 0.4
            }
        }
    }
}
