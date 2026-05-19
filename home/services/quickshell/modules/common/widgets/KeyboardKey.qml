import qs.modules.common
import QtQuick

Rectangle {
    id: root
    property string key

    property real horizontalPadding: 6
    property real verticalPadding: 1
    property real borderWidth: 1
    property real extraBottomBorderWidth: 2
    property color borderColor: Appearance.colors.colOnLayer0
    property real borderRadius: 5
    property real pixelSize: Appearance.typography.smaller
    property color keyColor: Appearance.colors.surfaceContainerLow
    implicitWidth: keyFace.implicitWidth + borderWidth * 2
    implicitHeight: keyFace.implicitHeight + borderWidth * 2 + extraBottomBorderWidth
    radius: borderRadius
    color: borderColor

    Rectangle {
        id: keyFace
        anchors {
            fill: parent
            topMargin: root.borderWidth
            leftMargin: root.borderWidth
            rightMargin: root.borderWidth
            bottomMargin: root.extraBottomBorderWidth + root.borderWidth
        }
        implicitWidth: keyText.implicitWidth + root.horizontalPadding * 2
        implicitHeight: keyText.implicitHeight + root.verticalPadding * 2
        color: root.keyColor
        radius: root.borderRadius - root.borderWidth

        Text {
            id: keyText
            anchors.centerIn: parent
            renderType: Text.NativeRendering
            font.family: Appearance.typography.monospace
            font.pixelSize: root.pixelSize
            color: Appearance.colors.colOnLayer0
            text: root.key
        }
    }
}
