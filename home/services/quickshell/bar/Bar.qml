import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components.controls
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
            spacing: 10

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
            spacing: 10

            BarGroup {
                Layout.alignment: Qt.AlignHCenter
                padding: 6
                rowSpacing: 8

                Resources {}
                BarSeparator { length: 16 }
                MediaIndicator {}
            }

            BarGroup {
                Layout.alignment: Qt.AlignHCenter
                padding: 4
                rowSpacing: 0

                Workspaces {}
            }

            BarGroup {
                Layout.alignment: Qt.AlignHCenter
                padding: 6
                rowSpacing: 8

                Clock {}
                Battery {}
            }
        }

        ColumnLayout {
            id: bottomGroup
            anchors {
                bottom: parent.bottom
                bottomMargin: 12
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 10

            BarGroup {
                Layout.alignment: Qt.AlignHCenter
                padding: 6
                rowSpacing: 10
                visible: net.visible || bt.visible

                Network  { id: net }
                Bluetooth { id: bt }
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
