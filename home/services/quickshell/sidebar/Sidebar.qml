import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.components
import qs.sidebar.quickToggles
import qs.utils

Scope {
    id: scope

    IpcHandler {
        target: "sidebar"
        function toggle(): void { Config.showSidebar = !Config.showSidebar; }
        function open(): void { Config.showSidebar = true; }
        function close(): void { Config.showSidebar = false; }
    }

    PanelWindow {
        id: triggerWin
        screen: Config.preferredMonitor
        visible: !Config.showSidebar

        anchors {
            right: true
            top: true
        }

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:sidebar:trigger"
        color: "transparent"

        implicitWidth: 12
        implicitHeight: 120

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: Config.showSidebar = true
        }
    }

    PanelWindow {
        id: sideWin

        screen: Config.preferredMonitor
        visible: true

        anchors {
            right: true
            top: true
            bottom: true
        }

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:sidebar"
        WlrLayershell.keyboardFocus: Config.showSidebar ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        implicitWidth: Config.sidebarWidth

        margins.right: Config.showSidebar ? 0 : -Config.sidebarWidth

        Behavior on margins.right {
            NumberAnimation {
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        HyprlandFocusGrab {
            id: grab
            windows: [sideWin]
            active: Config.showSidebar
            onCleared: Config.showSidebar = false
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape)
                Config.showSidebar = false;
        }

        Rectangle {
            anchors {
                fill: parent
                margins: 8
                topMargin:    Config.barPosition === "top"    ? Config.barHeight + 8 : 8
                bottomMargin: Config.barPosition === "bottom" ? Config.barHeight + 8 : 8
            }
            radius: Config.radius
            color: Colors.background
            layer.enabled: true

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 22
                anchors.bottomMargin: 22
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                spacing: 16

                Header {
                    Layout.leftMargin: 22
                    Layout.rightMargin: 22
                }

                Divider {
                    Layout.fillWidth: true
                    Layout.leftMargin: 22
                    Layout.rightMargin: 22
                    opacity: 0.5
                }

                ToggleGrid {
                    Layout.fillWidth: true
                    Layout.leftMargin: 22
                    Layout.rightMargin: 22
                    Layout.topMargin: 8
                }

                MediaCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 260
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                    Layout.topMargin: 4
                }

                NotificationCenter {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.preferredHeight: 356
                    Layout.leftMargin: 8
                    Layout.rightMargin: 8
                }

                NotificationToolbar {
                    Layout.leftMargin: 22
                    Layout.rightMargin: 22
                    Layout.bottomMargin: 12
                }
            }
        }
    }
}
