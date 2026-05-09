import QtQuick
import QtQuick.Layouts
import qs.utils

// Slim header strip for sidebar context menus: back arrow + title +
// optional trailing icon button. Includes the hairline divider beneath.
ColumnLayout {
    id: root

    property string title: ""
    property string trailingIcon: ""

    signal back()
    signal trailingClicked()

    Layout.fillWidth: true
    spacing: Config.layout.gapSm

    RowLayout {
        Layout.fillWidth: true
        spacing: Config.layout.gapMd

        Item {
            implicitWidth: 28
            implicitHeight: 28

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: backMa.containsMouse ? Colors.colLayer2Hover : "transparent"
                Behavior on color { Motion.ColorFade {} }
            }

            Text {
                anchors.centerIn: parent
                text: "arrow_back"
                color: Colors.colOnLayer2
                font.family: Config.typography.iconFamily
                font.pixelSize: 18
            }

            MouseArea {
                id: backMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.back()
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.title
            color: Colors.colOnLayer2
            font.family: Config.typography.family
            font.pixelSize: Config.typography.normal
            font.weight: Config.typography.weightMedium
            elide: Text.ElideRight
        }

        Item {
            visible: root.trailingIcon.length > 0
            implicitWidth: 28
            implicitHeight: 28

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: trailMa.containsMouse ? Colors.colLayer2Hover : "transparent"
                Behavior on color { Motion.ColorFade {} }
            }

            Text {
                anchors.centerIn: parent
                text: root.trailingIcon
                color: Colors.colOnLayer2
                font.family: Config.typography.iconFamily
                font.pixelSize: 18
            }

            MouseArea {
                id: trailMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.trailingClicked()
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: Config.layout.gapXs
        implicitHeight: 1
        color: Colors.outlineVariant
        opacity: 0.4
    }
}
