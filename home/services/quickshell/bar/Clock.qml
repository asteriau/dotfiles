import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.components
import qs.utils

WrapperMouseArea {
    onClicked: () => {
        NotificationState.notifOverlayOpen = false;
        Config.showSidebar = !Config.showSidebar;
    }

    implicitWidth: 38
    implicitHeight: hours.implicitHeight + minutes.implicitHeight + 2 + 20

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Colors.elevated

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 2

            Text {
                id: hours
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(Utils.clock.date, "hh")
                font.pixelSize: 14
                font.family: "Google Sans Flex"
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: minutes
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(Utils.clock.date, "mm")
                font.pixelSize: 14
                font.family: "Google Sans Flex"
                color: Colors.foreground
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
