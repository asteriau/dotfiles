pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

Item {
    id: root

    property alias model: repeater.model
    property int currentIndex: 0
    property bool expanded: true

    signal navigated(int index)
    signal toggleExpanded

    component NavRailItem: Item {
        id: item
        required property var modelData
        required property int index

        readonly property string icon: modelData.icon
        readonly property string label: modelData.name
        readonly property bool selected: root.currentIndex === index

        Layout.fillWidth: true
        implicitHeight: root.expanded ? 56 : 64

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            x: root.expanded ? 0 : (parent.width - width) / 2
            width:  root.expanded ? parent.width : 56
            height: root.expanded ? 36 : 52
            radius: 16

            color: item.selected
                ? (ma.containsMouse ? Colors.accentHover : Colors.accent)
                : (ma.containsMouse ? Colors.hover : Colors.transparent)

            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
            Behavior on width { NumberAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.OutCubic } }
            Behavior on x     { NumberAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.OutCubic } }
        }

        // Collapsed: icon above label
        ColumnLayout {
            visible: !root.expanded
            anchors.centerIn: parent
            spacing: 2

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: item.icon
                font.pointSize: Config.typography.huge
                fill: item.selected ? 1 : 0
                color: item.selected ? Colors.accentText : Colors.m3onSurfaceVariant
                Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: item.label
                font.family: Config.typography.family
                font.pixelSize: Config.typography.smaller
                font.weight: item.selected ? Font.Medium : Font.Normal
                color: item.selected ? Colors.accentText : Colors.m3onSurfaceVariant
                Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
            }
        }

        // Expanded: icon + label row
        RowLayout {
            visible: root.expanded
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            spacing: 12

            MaterialIcon {
                text: item.icon
                font.pointSize: Config.typography.huge
                fill: item.selected ? 1 : 0
                color: item.selected ? Colors.accentText : Colors.m3onSurfaceVariant
                Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
            }

            Text {
                Layout.fillWidth: true
                text: item.label
                font.family: Config.typography.family
                font.pixelSize: Config.typography.small
                font.weight: item.selected ? Font.Medium : Font.Normal
                color: item.selected ? Colors.accentText : Colors.m3onSurfaceVariant
                Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.navigated(item.index)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Expand/collapse chevron
        Item {
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: chevronMa.containsMouse ? Colors.hover : Colors.transparent
                Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }

                MaterialIcon {
                    anchors.centerIn: parent
                    text: root.expanded ? "menu_open" : "menu"
                    font.pointSize: Config.typography.huge
                    color: Colors.m3onSurfaceVariant
                }

                MouseArea {
                    id: chevronMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleExpanded()
                }
            }
        }

        Item { Layout.preferredHeight: 8 }

        Repeater {
            id: repeater
            delegate: NavRailItem {}
        }

        Item { Layout.fillHeight: true }
    }
}
