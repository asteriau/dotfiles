import QtQuick
import qs.components.controls
import qs.utils

Rectangle {
    id: root
    color: Colors.background

    Row {
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        SidebarToggle { anchors.verticalCenter: parent.verticalCenter }
        ActiveWindow  { anchors.verticalCenter: parent.verticalCenter }
    }

    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
        spacing: 6

        BarGroup {
            anchors.verticalCenter: parent.verticalCenter
            padding: 6
            columnSpacing: 8

            Resources {}
            BarSeparator { length: 14 }
            MediaIndicator {}
        }

        Workspaces { anchors.verticalCenter: parent.verticalCenter }

        BarGroup {
            anchors.verticalCenter: parent.verticalCenter
            padding: 6
            columnSpacing: 8

            Clock {}
        }
    }

    Row {
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        WeatherBar { anchors.verticalCenter: parent.verticalCenter }
        Tray       { vertical: false; anchors.verticalCenter: parent.verticalCenter }

        BarGroup {
            anchors.verticalCenter: parent.verticalCenter
            padding: 6
            columnSpacing: 8
            visible: net.visible || bt.visible || batt.visible

            Network   { id: net }
            Bluetooth { id: bt }
            Battery   { id: batt; vertical: false }
        }
    }
}
