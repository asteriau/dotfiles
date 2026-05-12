// Tappable row that toggles a switch when clicked anywhere.
import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.components.text
import qs.utils

Rectangle {
    id: root

    property string text: ""
    property string icon: ""
    property string caption: ""
    property bool checked: false

    signal toggled(bool value)

    function flash() { flashAnim.restart(); }

    Layout.fillWidth: true
    implicitHeight: Math.max(56, contentRow.implicitHeight + 16)
    color: ma.pressed ? Appearance.colors.pressed
                      : (ma.containsMouse ? Appearance.colors.hover : Appearance.colors.transparent)
    radius: Appearance.layout.radiusLg
    Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

    Rectangle {
        id: flashRect
        anchors.fill: parent
        color: Appearance.colors.accent
        opacity: 0
        SequentialAnimation {
            id: flashAnim
            NumberAnimation { target: flashRect; property: "opacity"; from: 0; to: 0.22; duration: 180; easing.type: Easing.OutCubic }
            PauseAnimation  { duration: 280 }
            NumberAnimation { target: flashRect; property: "opacity"; to: 0; duration: 520; easing.type: Easing.OutCubic }
        }
    }

    Item {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        implicitHeight: Math.max(iconBadge.height, labelCol.implicitHeight, switchCtl.height)

        Rectangle {
            id: iconBadge
            visible: root.icon.length > 0
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 36
            height: 36
            radius: 18
            color: root.checked ? Appearance.colors.accent : Appearance.colors.surfaceContainerHigh
            Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

            MaterialIcon {
                anchors.centerIn: parent
                text: root.icon
                font.pointSize: Appearance.typography.large
                fill: root.checked ? 1 : 0
                color: root.checked ? Appearance.colors.accentText : Appearance.colors.m3onSurfaceVariant
                Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }
            }
        }

        StyledSwitch {
            id: switchCtl
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: root.checked
            onToggled: val => {
                root.checked = val;
                root.toggled(val);
            }
        }

        ColumnLayout {
            id: labelCol
            anchors.left: iconBadge.visible ? iconBadge.right : parent.left
            anchors.leftMargin: iconBadge.visible ? Appearance.layout.gapLg : 0
            anchors.right: switchCtl.left
            anchors.rightMargin: Appearance.layout.gapLg
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            StyledText {
                Layout.fillWidth: true
                text: root.text
                color: Appearance.colors.foreground
                font.pixelSize: Appearance.typography.small
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            StyledText {
                Layout.fillWidth: true
                visible: root.caption.length > 0
                text: root.caption
                color: Appearance.colors.m3onSurfaceVariant
                font.pixelSize: Appearance.typography.smaller
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const next = !root.checked;
            root.checked = next;
            root.toggled(next);
        }
    }
}
