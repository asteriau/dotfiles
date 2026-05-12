import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

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
        anchors.leftMargin: Appearance.layout.gapXl
        anchors.rightMargin: Appearance.layout.gapXl
        anchors.topMargin: Appearance.layout.gapMd
        anchors.bottomMargin: Appearance.layout.gapMd
        spacing: Appearance.layout.gapLg

        StyledText {
            text: root.label
            color: Appearance.colors.m3onSurfaceVariant
            font.pixelSize: Appearance.typography.small
            Layout.preferredWidth: 100
        }

        StyledText {
            text: root.value
            color: Appearance.colors.foreground
            font.pixelSize: Appearance.typography.small
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
