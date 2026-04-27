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

    Layout.fillWidth: true
    implicitHeight: Math.max(Config.layout.rowMinHeight, contentRow.implicitHeight + 16)
    radius: Config.layout.radiusMd

    color: ma.containsMouse ? Colors.hoverFaint : Colors.transparent
    Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }

    RowLayout {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 12

        MaterialIcon {
            visible: root.icon.length > 0
            text: root.icon
            font.pointSize: Config.typography.huge
            fill: root.checked ? 1 : 0
            color: root.checked ? Colors.accent : Colors.m3onSurfaceVariant
            Layout.preferredWidth: 24
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            StyledText {
                text: root.text
                color: Colors.foreground
                font.pixelSize: Config.typography.small
            }

            StyledText {
                visible: root.caption.length > 0
                text: root.caption
                color: Colors.comment
                font.pixelSize: Config.typography.smaller
            }
        }

        StyledSwitch {
            Layout.alignment: Qt.AlignVCenter
            checked: root.checked
            onToggled: val => {
                root.checked = val;
                root.toggled(val);
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
