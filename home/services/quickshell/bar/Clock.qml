import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

Item {
    id: root

    property bool vertical: Config.bar.vertical
    readonly property bool horizontal: !vertical

    readonly property string hh:    Qt.formatDateTime(Utils.clock.date, "hh")
    readonly property string mm:    Qt.formatDateTime(Utils.clock.date, "mm")
    readonly property string hhmm:  Qt.formatDateTime(Utils.clock.date, "hh:mm")
    readonly property string ddmm:  Qt.formatDateTime(Utils.clock.date, "dd/MM")

    implicitWidth:  horizontal ? hRow.implicitWidth : col.implicitWidth
    implicitHeight: horizontal ? Config.bar.height : col.implicitHeight

    // Vertical: stacked hh / mm / dd-MM with rolling digits.
    ColumnLayout {
        id: col
        visible: root.vertical
        anchors.centerIn: parent
        spacing: 6

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: -4

            RollingText {
                Layout.alignment: Qt.AlignHCenter
                text: root.hh
                pixelSize: Config.typography.large
                family: Config.typography.family
                color: Colors.foreground
            }

            RollingText {
                Layout.alignment: Qt.AlignHCenter
                text: root.mm
                pixelSize: Config.typography.large
                family: Config.typography.family
                color: Colors.foreground
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
            text: root.ddmm
            font.pixelSize: Config.typography.smallest
            font.family: Config.typography.family
            color: Colors.m3onSurfaceInactive
            horizontalAlignment: Text.AlignHCenter
        }
    }

    // Horizontal: hh:mm • dd/MM with rolling hh:mm.
    RowLayout {
        id: hRow
        visible: root.horizontal
        anchors.centerIn: parent
        spacing: 6

        RollingText {
            text: root.hhmm
            pixelSize: Config.typography.large
            family: Config.typography.family
            color: Colors.foreground
        }

        StyledText {
            text: "•"
            font.pixelSize: Config.typography.small
            color: Colors.m3onSurfaceInactive
        }

        StyledText {
            text: root.ddmm
            font.pixelSize: Config.typography.small
            font.family: Config.typography.family
            color: Colors.m3onSurfaceInactive
        }
    }
}
