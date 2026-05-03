// Top row of a notification: summary / time + expand chevron pill.
import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

Item {
    id: root

    property string summary: ""
    property string timeString: ""
    property bool expanded: false
    property int count: 1

    signal toggleExpanded

    implicitHeight: Math.max(topTextRow.implicitHeight, expandBtn.implicitHeight)

    RowLayout {
        id: topTextRow
        anchors.left: parent.left
        anchors.right: expandBtn.left
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        StyledText {
            Layout.fillWidth: true
            text: root.summary
            color: Colors.foreground
            font.pixelSize: Config.typography.small
            font.weight: Font.DemiBold
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        StyledText {
            Layout.rightMargin: 6
            text: root.timeString
            variant: StyledText.Variant.Caption
        }
    }

    // Chevron pill (toggles expanded).
    Rectangle {
        id: expandBtn
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        readonly property bool hovered: pillMouse.containsMouse

        implicitHeight: Config.typography.smaller + 8
        implicitWidth: Math.max(30, pillRow.implicitWidth + 10)
        radius: height / 2
        color: pillMouse.pressed ? Colors.pressedStrong
             : hovered           ? Colors.hoverStrongest
             :                     Colors.hover
        antialiasing: true

        Behavior on color {
            ColorAnimation { duration: M3Easing.durationShort2 }
        }

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 2

            StyledText {
                visible: root.count > 1
                text: root.count
                font.pixelSize: Config.typography.smaller
                color: Colors.foreground
                anchors.verticalCenter: parent.verticalCenter
            }

            MaterialIcon {
                id: chevron
                text: "keyboard_arrow_down"
                color: Colors.foreground
                pixelSize: Config.typography.normal
                rotation: root.expanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: M3Easing.durationMedium1
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: M3Easing.emphasized
                    }
                }
            }
        }

        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => {
                mouse.accepted = true;
                root.toggleExpanded();
            }
        }
    }
}
