pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.modules.common.widgets

Item {
    id: root
    property int selectionMode: 0   // 0 = Rect, 1 = Circle
    signal dismiss()

    implicitWidth: bg.implicitWidth
    implicitHeight: bg.implicitHeight

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Appearance.colors.surfaceContainer
        radius: height / 2
        implicitHeight: 56
        implicitWidth: rowItem.implicitWidth + 16

        RowLayout {
            id: rowItem
            anchors {
                fill: parent
                margins: 8
            }
            spacing: 4

            Repeater {
                model: [
                    { icon: "crop_free", name: "Rect", mode: 0 },
                    { icon: "gesture", name: "Circle", mode: 1 }
                ]
                delegate: Rectangle {
                    id: tab
                    required property var modelData
                    required property int index
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: tabRow.implicitWidth + 20
                    radius: height / 2
                    color: root.selectionMode === modelData.mode
                        ? Appearance.colors.secondaryContainer
                        : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }

                    Row {
                        id: tabRow
                        anchors.centerIn: parent
                        spacing: 6
                        MaterialIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            text: tab.modelData.icon
                            pixelSize: 22
                            color: Appearance.colors.m3onSurface
                        }
                        StyledText {
                            anchors.verticalCenter: parent.verticalCenter
                            text: tab.modelData.name
                            color: Appearance.colors.m3onSurface
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectionMode = tab.modelData.mode
                    }
                }
            }
        }
    }
}
