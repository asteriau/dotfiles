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
            id: stack
            anchors.fill: parent
            anchors.topMargin: 16
            anchors.bottomMargin: 10
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            spacing: 8

            NixIcon {
                Layout.alignment: Qt.AlignHCenter
            }

            Workspaces {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            }

            Tray {
                Layout.alignment: Qt.AlignHCenter
            }

            Status {
                Layout.alignment: Qt.AlignHCenter
            }

            Battery {
                Layout.alignment: Qt.AlignHCenter
            }

            Clock {
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
