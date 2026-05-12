import QtQuick
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

HoverTooltip {
    id: root

    required property string buttonText

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    Rectangle {
        radius: Appearance.layout.cardRadius
        color: root.containsMouse ? Appearance.colors.buttonDisabledHover : Appearance.colors.buttonDisabled
        implicitHeight: text.height + 2 * Appearance.padding
        implicitWidth: parent.width || text.width + 2 * Appearance.padding
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
