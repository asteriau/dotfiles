import QtQuick
import QtQuick.Layouts
import qs.components.surfaces
import qs.components.text
import qs.utils

PressablePill {
    id: root

    property string icon
    property string label
    property string sub

    radius: Config.layout.radiusXxl
    pressScale: 0.97
    colorActiveHover: colorActive    // preserve original: no hover-lightening when active

    Layout.fillWidth: true
    Layout.preferredHeight: Config.layout.tileLargeHeight
    implicitHeight: Config.layout.tileLargeHeight

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            radius: Config.layout.radiusXl
            color: root.active ? Qt.rgba(0.102, 0.145, 0.188, 0.18) : Colors.surfaceContainerHighest
            antialiasing: true

            MaterialIcon {
                anchors.centerIn: parent
                text: root.icon
                pixelSize: 22
                fill: root.active ? 1 : 0
                grade: 0
                color: root.active ? Colors.m3onPrimary : Colors.foreground

                Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            StyledText {
                Layout.fillWidth: true
                text: root.label
                color: root.active ? Colors.m3onPrimary : Colors.foreground
                font.pixelSize: 14
                font.weight: Font.Medium
                font.letterSpacing: -0.14
                elide: Text.ElideRight

                Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.sub
                visible: root.sub.length > 0
                color: root.active
                    ? Qt.rgba(Colors.m3onPrimary.r, Colors.m3onPrimary.g, Colors.m3onPrimary.b, 0.75)
                    : Colors.m3onSurfaceVariant
                font.pixelSize: 11
                opacity: 0.8
                elide: Text.ElideRight
            }
        }
    }
}
