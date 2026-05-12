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
            id: bg
            anchors.verticalCenter: parent.verticalCenter
            x: root.expanded ? 0 : (parent.width - width) / 2
            width:  root.expanded ? parent.width : 56
            height: root.expanded ? 40 : 52
            radius: Config.layout.radiusXl
            color: Appearance.colors.transparent

            Behavior on width  { NumberAnimation { duration: Appearance.motion.duration.spatial; easing.type: Easing.OutCubic } }
            Behavior on x      { NumberAnimation { duration: Appearance.motion.duration.spatial; easing.type: Easing.OutCubic } }

            // Hover overlay (only when not selected)
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Appearance.colors.hover
                opacity: !item.selected && ma.containsMouse ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
            }

            // Selected fill
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: ma.containsMouse ? Qt.lighter(Appearance.colors.primaryContainer, 1.05) : Appearance.colors.primaryContainer
                opacity: item.selected ? 1 : 0
                Behavior on color   { ColorAnimation  { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
            }
        }

        // Collapsed: icon only (centered)
        MaterialIcon {
            visible: !root.expanded
            anchors.centerIn: parent
            text: item.icon
            font.pointSize: Config.typography.huge
            fill: item.selected ? 1 : 0
            color: item.selected ? Appearance.colors.m3onPrimaryContainer : Appearance.colors.m3onSurfaceVariant
            Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }
            Behavior on fill  { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
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
                color: item.selected ? Appearance.colors.m3onPrimaryContainer : Appearance.colors.m3onSurfaceVariant
                Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }
                Behavior on fill  { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
            }

            Text {
                Layout.fillWidth: true
                text: item.label
                font.family: Config.typography.family
                font.pixelSize: Config.typography.small
                font.weight: item.selected ? Font.Medium : Font.Normal
                color: item.selected ? Appearance.colors.m3onPrimaryContainer : Appearance.colors.m3onSurfaceVariant
                Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }
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
        spacing: 4

        // Expand/collapse chevron
        Item {
            Layout.preferredHeight: 40
            Layout.preferredWidth: 40
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: chevronMa.containsMouse ? Appearance.colors.hover : Appearance.colors.transparent
                Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

                MaterialIcon {
                    anchors.centerIn: parent
                    text: root.expanded ? "menu_open" : "menu"
                    font.pointSize: Config.typography.huge
                    color: Appearance.colors.m3onSurfaceVariant
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
