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
        top: true
        left: true
        bottom: true
    }
    implicitWidth: Config.barWidth

    color: "transparent"

    Rectangle {
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

            MoonIcon {
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
}
