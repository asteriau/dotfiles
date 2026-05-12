import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components.text
import qs.utils

Rectangle {
    id: root
    property string label: ""
    property string value: ""

    Layout.fillWidth: true
    implicitHeight: 48
    color: ma.containsMouse ? Appearance.colors.hover : Appearance.colors.transparent
    radius: 0
    Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 12

        StyledText {
            text: root.label
            color: Appearance.colors.m3onSurfaceVariant
            font.pixelSize: Config.typography.small
            Layout.preferredWidth: 100
        }

        StyledText {
            text: root.value
            color: Appearance.colors.foreground
            font.pixelSize: Config.typography.small
            font.weight: Font.Medium
            elide: Text.ElideRight
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.RightButton
        cursorShape: Qt.IBeamCursor
        onClicked: Quickshell.clipboardText = root.value
    }
}
