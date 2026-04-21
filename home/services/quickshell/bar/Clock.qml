import QtQuick
import QtQuick.Layouts
import qs.utils

Item {
    property bool horizontal: !Config.barVertical

    implicitWidth:  horizontal ? (hRow.implicitWidth + 20) : 32
    implicitHeight: horizontal ? (Config.barHeight - 8)    : (col.implicitHeight + 16)

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Colors.elevated

        // Vertical mode: stacked hh / mm / date
        ColumnLayout {
            id: col
            visible: !horizontal
            anchors.centerIn: parent
            spacing: 2

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(Utils.clock.date, "hh")
                font.pixelSize: 13
                font.family: "Google Sans Flex"
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(Utils.clock.date, "mm")
                font.pixelSize: 13
                font.family: "Google Sans Flex"
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 3
                implicitWidth: 20
                implicitHeight: 1
                color: Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.15)
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 3
                text: Qt.formatDateTime(Utils.clock.date, "dd/MM")
                font.pixelSize: 10
                font.family: "Google Sans Flex"
                color: Colors.comment
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Horizontal mode: inline "hh:mm · dd/MM"
        RowLayout {
            id: hRow
            visible: horizontal
            anchors.centerIn: parent
            spacing: 4

            Text {
                text: Qt.formatDateTime(Utils.clock.date, "hh:mm")
                font.pixelSize: 13
                font.family: "Google Sans Flex"
                color: Colors.foreground
            }

            Rectangle {
                implicitWidth: 1
                implicitHeight: 12
                color: Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.2)
            }

            Text {
                text: Qt.formatDateTime(Utils.clock.date, "dd/MM")
                font.pixelSize: 11
                font.family: "Google Sans Flex"
                color: Colors.comment
            }
        }
    }
}
