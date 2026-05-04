import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.components.surfaces
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

        implicitWidth: Config.sidebar.width

        margins.right: Config.showSidebar ? 0 : -Config.sidebar.width

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
                topMargin:    Config.bar.position === "top"    ? Config.bar.height + 8 : 8
                bottomMargin: Config.bar.position === "bottom" ? Config.bar.height + 8 : 8
            }
            radius: Config.layout.cardRadius
            color: Colors.background
            layer.enabled: true

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: Config.layout.gapXl + 4
                anchors.bottomMargin: Config.layout.gapLg
                anchors.leftMargin: 0
                anchors.rightMargin: 0
                spacing: Config.layout.gapLg

                Header {
                    Layout.leftMargin: Config.layout.gapXl + 4
                    Layout.rightMargin: Config.layout.gapXl + 4
                    Layout.bottomMargin: Config.layout.gapLg
                }

                QuickToggles {
                    Layout.fillWidth: true
                    Layout.leftMargin: Config.layout.gapLg
                    Layout.rightMargin: Config.layout.gapLg
                    Layout.bottomMargin: Config.layout.gapLg
                }

                QuickSliders {
                    Layout.fillWidth: true
                    Layout.leftMargin: Config.layout.gapLg
                    Layout.rightMargin: Config.layout.gapLg
                    Layout.bottomMargin: Config.layout.gapLg
                }

                NotificationCenter {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.leftMargin: Config.layout.gapMd
                    Layout.rightMargin: Config.layout.gapMd
                }

                NotificationToolbar {
                    Layout.leftMargin: Config.layout.gapXl + 4
                    Layout.rightMargin: Config.layout.gapXl + 4
                }
            }
        }
    }
}
