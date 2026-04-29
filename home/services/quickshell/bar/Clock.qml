import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

Item {
    id: root

    property bool vertical: Config.bar.vertical
    readonly property bool horizontal: !vertical

    implicitWidth:  horizontal ? hRow.implicitWidth : col.implicitWidth
    implicitHeight: horizontal ? Config.bar.height : col.implicitHeight

    // Stacked hh / mm / dd-MM in vertical bar.
    ColumnLayout {
        id: col
        visible: root.vertical
        anchors.centerIn: parent
        spacing: 6

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            // Tight stack between hh and mm imitates a digital-clock face.
            spacing: -4

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(Utils.clock.date, "hh")
                font.pixelSize: Config.typography.large
                font.family: Config.typography.family
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(Utils.clock.date, "mm")
                font.pixelSize: Config.typography.large
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
            font.pixelSize: Config.typography.smallest
            font.family: Config.typography.family
            color: Colors.m3onSurfaceInactive
            horizontalAlignment: Text.AlignHCenter
        }
    }

    RowLayout {
        id: hRow
        visible: root.horizontal
        anchors.centerIn: parent
        spacing: 6

        StyledText {
            text: Qt.formatDateTime(Utils.clock.date, "hh:mm")
            font.pixelSize: Config.typography.large
            font.family: Config.typography.family
            color: Colors.foreground
        }

        StyledText {
            text: "•"
            font.pixelSize: Config.typography.small
            color: Colors.m3onSurfaceInactive
        }

        StyledText {
            text: Qt.formatDateTime(Utils.clock.date, "dd/MM")
            font.pixelSize: Config.typography.small
            font.family: Config.typography.family
            color: Colors.m3onSurfaceInactive
        }
    }
}
