import QtQuick
import qs.utils

Rectangle {
    id: root
    color: Colors.background

    // Left: sidebar toggle.
    Row {
        anchors {
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
        }

        SidebarToggle {}
    }

    // Center: workspaces.
    Row {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        Workspaces {}
    }

    // Right: tray + network + bluetooth + battery + clock.
    Row {
        anchors {
            right: parent.right
            rightMargin: 10
            verticalCenter: parent.verticalCenter
        }
        spacing: 8

        Tray      { vertical: false; anchors.verticalCenter: parent.verticalCenter }
        Network   { anchors.verticalCenter: parent.verticalCenter }
        Bluetooth { anchors.verticalCenter: parent.verticalCenter }
        Battery   { vertical: false; anchors.verticalCenter: parent.verticalCenter }
        Clock     { anchors.verticalCenter: parent.verticalCenter }
    }
}
