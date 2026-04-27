import QtQuick
import QtQuick.Layouts
import qs.utils

Rectangle {
    id: root

    property string text: ""
    signal edited(string newValue)

    Layout.fillWidth: true
    Layout.preferredWidth: 240
    Layout.topMargin: 2
    implicitHeight: 36
    radius: Config.layout.radiusMd
    color: Colors.background
    border.width: 1
    border.color: Colors.divider

    TextInput {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        verticalAlignment: TextInput.AlignVCenter
        text: root.text
        color: Colors.foreground
        font.family: Config.typography.family
        font.pixelSize: Config.typography.smallie
        selectByMouse: true
        onEditingFinished: root.edited(text)
    }
}
