import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property string text: ""
    signal edited(string newValue)

    Layout.fillWidth: true
    implicitHeight: 56

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: Appearance.layout.gapXl
        anchors.rightMargin: Appearance.layout.gapXl
        anchors.topMargin: Appearance.layout.gapMd
        anchors.bottomMargin: Appearance.layout.gapMd
        radius: Appearance.layout.radiusMd
        color: Appearance.colors.colLayer3

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: Appearance.layout.gapXl
            anchors.rightMargin: Appearance.layout.gapXl
            verticalAlignment: TextInput.AlignVCenter
            text: root.text
            color: Appearance.colors.foreground
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.small
            selectByMouse: true
            onEditingFinished: root.edited(text)
        }
    }
}
