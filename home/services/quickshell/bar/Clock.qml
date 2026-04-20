import QtQuick
import QtQuick.Layouts
import qs.utils

Item {
    implicitWidth: 32
    implicitHeight: col.implicitHeight + 16

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Colors.elevated

        ColumnLayout {
            id: col
            anchors.centerIn: parent
            spacing: 2

            Text {
                id: hours
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(Utils.clock.date, "hh")
                font.pixelSize: 13
                font.family: "Google Sans Flex"
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: minutes
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
                id: date
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 3
                text: Qt.formatDateTime(Utils.clock.date, "dd/MM")
                font.pixelSize: 10
                font.family: "Google Sans Flex"
                color: Colors.comment
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
