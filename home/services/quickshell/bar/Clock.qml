import QtQuick
import QtQuick.Layouts
import qs.utils
import qs.components

Item {
    property bool horizontal: !Config.barVertical

    implicitWidth:  horizontal ? (hRow.implicitWidth + 20) : Config.barWidth
    implicitHeight: horizontal ? Config.barHeight : (col.implicitHeight + 16)

    Rectangle {
        anchors {
            fill: parent
            topMargin:    horizontal ? 4 : 0
            bottomMargin: horizontal ? 4 : 0
            leftMargin:   0
            rightMargin:  0
        }
        radius: 12
        color: Colors.elevated

        // Vertical mode: stacked hh / mm / date
        ColumnLayout {
            id: col
            visible: !horizontal
            anchors.centerIn: parent
            spacing: 6

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: -4

                ShadowText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(Utils.clock.date, "hh")
                    font.pixelSize: 17
                    font.family: Config.fontFamily
                    color: Colors.foreground
                    horizontalAlignment: Text.AlignHCenter
                }

                ShadowText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(Utils.clock.date, "mm")
                    font.pixelSize: 17
                    font.family: Config.fontFamily
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

            ShadowText {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(Utils.clock.date, "dd/MM")
                font.pixelSize: 10
                font.family: Config.fontFamily
                color: Colors.m3onSurfaceInactive
                horizontalAlignment: Text.AlignHCenter
            }
        }

        // Horizontal mode: inline "hh:mm · dd/MM"
        RowLayout {
            id: hRow
            visible: horizontal
            anchors.centerIn: parent
            spacing: 4

            ShadowText {
                text: Qt.formatDateTime(Utils.clock.date, "hh:mm")
                font.pixelSize: 17
                font.family: Config.fontFamily
                color: Colors.foreground
            }

            Rectangle {
                implicitWidth: 1
                implicitHeight: 14
                color: Colors.divider
            }

            ShadowText {
                text: Qt.formatDateTime(Utils.clock.date, "dd/MM")
                font.pixelSize: 13
                font.family: Config.fontFamily
                color: Colors.m3onSurfaceInactive
            }
        }
    }
}
