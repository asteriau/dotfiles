import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common

RowLayout {
    id: root
    property string label: ""
    property string value: ""
    Layout.fillWidth: true
    spacing: 10

    StyledText {
        text: root.label
        color: Appearance.colors.colSubtext
        Layout.preferredWidth: 100
    }
    StyledText {
        text: root.value
        elide: Text.ElideRight
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: Quickshell.clipboardText = root.value
        }
    }
}
