import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.utils

RowLayout {
    id: root
    property string label: ""
    property string value: ""
    Layout.fillWidth: true
    spacing: 8

    Text {
        text: root.label
        color: Colors.comment
        font.family: Config.typography.family
        font.pixelSize: Config.typography.smallie
        Layout.preferredWidth: 96
    }

    Text {
        text: root.value
        color: Colors.foreground
        font.family: Config.typography.family
        font.pixelSize: Config.typography.smallie
        elide: Text.ElideRight
        Layout.fillWidth: true

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            cursorShape: Qt.IBeamCursor
            onClicked: Quickshell.clipboardText = root.value
        }
    }
}
