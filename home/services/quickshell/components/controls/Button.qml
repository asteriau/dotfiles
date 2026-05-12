import QtQuick
import qs.components.effects
import qs.utils

HoverTooltip {
    id: root

    required property string buttonText

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    Rectangle {
        radius: Config.layout.cardRadius
        color: root.containsMouse ? Appearance.colors.buttonDisabledHover : Appearance.colors.buttonDisabled
        implicitHeight: text.height + 2 * Config.padding
        implicitWidth: parent.width || text.width + 2 * Config.padding
        border {
            color: Appearance.colors.border
            width: 1
        }

        Text {
            id: text

            anchors.centerIn: parent
            text: root.buttonText
            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.Wrap
        }
    }
}
