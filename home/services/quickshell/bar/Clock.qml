import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

Item {
    id: root

    property bool vertical: Config.bar.vertical
    readonly property bool horizontal: !vertical

    implicitWidth:  horizontal ? (hRow.implicitWidth + 20) : Config.bar.width
    implicitHeight: horizontal ? Config.bar.height : (col.implicitHeight + 16)

    Rectangle {
        anchors {
            fill: parent
            topMargin:    root.horizontal ? 4 : 0
            bottomMargin: root.horizontal ? 4 : 0
            leftMargin:   0
            rightMargin:  0
        }
        radius: 12
        color: Colors.elevated

        // Vertical mode: stacked hh / mm / date
        ColumnLayout {
            id: col
            visible: root.vertical
            anchors.centerIn: parent
            spacing: 6

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: -4

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(Utils.clock.date, "hh")
                    font.pixelSize: 17
                    font.family: Config.typography.family
                    color: Colors.foreground
                    horizontalAlignment: Text.AlignHCenter
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(Utils.clock.date, "mm")
                    font.pixelSize: 17
                    font.family: Config.typography.family
                    color: Colors.foreground
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 20
                implicitHeight: 1
                color: Colors.divider
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(Utils.clock.date, "dd/MM")
                font.pixelSize: 10
                font.family: Config.typography.family
                color: Colors.m3onSurfaceInactive
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Horizontal mode: inline "hh:mm · dd/MM"
        RowLayout {
            id: hRow
            visible: root.horizontal
            anchors.centerIn: parent
            spacing: 4

            StyledText {
                text: Qt.formatDateTime(Utils.clock.date, "hh:mm")
                font.pixelSize: 17
                font.family: Config.typography.family
                color: Colors.foreground
            }

            Rectangle {
                implicitWidth: 1
                implicitHeight: 14
                color: Colors.divider
            }

            StyledText {
                text: Qt.formatDateTime(Utils.clock.date, "dd/MM")
                font.pixelSize: 13
                font.family: Config.typography.family
                color: Colors.m3onSurfaceInactive
            }
        }
    }
}
