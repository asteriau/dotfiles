pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

Item {
    id: root

    property string icon:     "volume_up"
    property string label:    ""
    property real   progress: 0
    property color  fillColor:  Colors.accent
    property color  trackColor: Colors.surfaceContainerHigh

    readonly property real barHeight: 4
    readonly property real clamped: Math.max(0, Math.min(1, progress))

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 20
        spacing: 8

        CrossfadeIcon {
            text: root.icon
            fill: 1
            pixelSize: 26
            color: Colors.foreground
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: root.barHeight / 2
                Layout.rightMargin: root.barHeight / 2

                StyledText {
                    Layout.fillWidth: true
                    variant: StyledText.Variant.Body
                    text: root.label
                }

                StyledText {
                    variant: StyledText.Variant.Body
                    text: Math.round(root.clamped * 100)
                    horizontalAlignment: Text.AlignRight
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.barHeight

                Rectangle {
                    id: fill
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    height: root.barHeight
                    radius: height / 2
                    color: root.fillColor
                    width: parent.width * root.clamped
                    Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: root.barHeight
                    width: Math.max(0, parent.width - fill.width - root.barHeight)
                    radius: height / 2
                    color: root.trackColor
                    Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.barHeight
                    height: root.barHeight
                    radius: height / 2
                    color: root.fillColor
                    Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
                }
            }
        }
    }
}
