import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.utils

PanelWindow {
    id: barWindow
    WlrLayershell.namespace: "quickshell:bar"
    screen: Config.preferredMonitor

    anchors {
        top:    Config.bar.vertical || !Config.bar.onEnd
        bottom: Config.bar.vertical || Config.bar.onEnd
        left:   !Config.bar.vertical || !Config.bar.onEnd
        right:  !Config.bar.vertical || Config.bar.onEnd
    }
    implicitWidth:  Config.bar.vertical ? Config.bar.width : 0
    implicitHeight: Config.bar.vertical ? 0 : Config.bar.height

    color: "transparent"

    Rectangle {
        visible: Config.bar.vertical
        anchors.fill: parent
        color: Colors.background

        ColumnLayout {
            id: topGroup
            anchors {
                top: parent.top
                topMargin: 16
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 12
            spacing: 8

            SidebarToggle {
                Layout.alignment: Qt.AlignHCenter
            }
        }

        ColumnLayout {
            id: centerGroup
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 12
            spacing: 8

            Workspaces {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            Clock {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }
        }

        ColumnLayout {
            id: bottomGroup
            anchors {
                bottom: parent.bottom
                bottomMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            width: parent.width - 12
            spacing: 8

            Status {
                Layout.alignment: Qt.AlignHCenter
            }

            Battery {
                Layout.alignment: Qt.AlignHCenter
            }

            Tray {
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    BarHorizontal {
        visible: !Config.bar.vertical
        anchors.fill: parent
    }
}
