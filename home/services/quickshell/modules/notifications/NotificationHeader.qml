import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

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
            color: Appearance.colors.foreground
            font.pixelSize: Appearance.typography.small
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

        implicitHeight: Appearance.typography.smaller + 8
        implicitWidth: Math.max(30, pillRow.implicitWidth + 10)
        radius: height / 2
        color: pillMouse.pressed ? Appearance.colors.pressedStrong
             : hovered           ? Appearance.colors.hoverStrongest
             :                     Appearance.colors.hover
        antialiasing: true

        Behavior on color {
            ColorAnimation { duration: Appearance.motion.duration.short2 }
        }

        Row {
            id: pillRow
            anchors.centerIn: parent
            spacing: 2

            StyledText {
                visible: root.count > 1
                text: root.count
                font.pixelSize: Appearance.typography.smaller
                color: Appearance.colors.foreground
                anchors.verticalCenter: parent.verticalCenter
            }

            MaterialIcon {
                id: chevron
                text: "keyboard_arrow_down"
                color: Appearance.colors.foreground
                pixelSize: Appearance.typography.normal
                rotation: root.expanded ? 180 : 0

                Behavior on rotation {
                    NumberAnimation {
                        duration: Appearance.motion.duration.medium1
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.emphasized
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
