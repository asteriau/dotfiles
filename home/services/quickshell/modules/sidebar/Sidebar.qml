import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.modules.common.widgets
import qs.modules.sidebar.menus
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Scope {
    id: scope

    IpcHandler {
        target: "sidebar"
        function toggle(): void { UiState.showSidebar = !UiState.showSidebar; }
        function open(): void { UiState.showSidebar = true; }
        function close(): void { UiState.showSidebar = false; }
    }

    PanelWindow {
        id: triggerWin
        screen: UiState.preferredMonitor
        visible: !UiState.showSidebar

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
            onEntered: UiState.showSidebar = true
        }
    }

    PanelWindow {
        id: sideWin

        screen: UiState.preferredMonitor
        visible: true

        anchors {
            right: true
            top: true
            bottom: true
        }

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:sidebar"
        WlrLayershell.keyboardFocus: UiState.showSidebar ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        implicitWidth: Config.sidebar.width

        margins.right: UiState.showSidebar ? 0 : -Config.sidebar.width

        Behavior on margins.right {
            NumberAnimation {
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        HyprlandFocusGrab {
            id: grab
            windows: [sideWin]
            active: UiState.showSidebar
            onCleared: {
                UiState.showSidebar = false;
                UiState.sidebarMenu = "none";
            }
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                if (UiState.sidebarMenu !== "none") {
                    UiState.sidebarMenu = "none";
                } else {
                    UiState.showSidebar = false;
                }
            }
        }

        Rectangle {
            anchors {
                fill: parent
                margins: 8
                topMargin:    Config.bar.position === "top"    ? Appearance.bar.height + 8 : 8
                bottomMargin: Config.bar.position === "bottom" ? Appearance.bar.height + 8 : 8
            }
            radius: Appearance.layout.cardRadius
            color: Appearance.colors.background
            layer.enabled: true

            // Chrome wrapped in a layer so we can blur it while a
            // context menu is open. Blur amount animates with the
            // dialog's emphasized motion duration.
            Item {
                id: chromeWrap
                anchors.fill: parent

                property real blurAmt: UiState.sidebarMenu !== "none" ? 1.0 : 0.0
                Behavior on blurAmt {
                    NumberAnimation {
                        duration: Appearance.motion.duration.medium3
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.emphasized
                    }
                }

                layer.enabled: chromeWrap.blurAmt > 0.001
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blurMax: 32
                    blur: chromeWrap.blurAmt
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: Appearance.layout.gapXl + 4
                    anchors.bottomMargin: Appearance.layout.gapLg
                    anchors.leftMargin: 0
                    anchors.rightMargin: 0
                    spacing: Appearance.layout.gapLg

                    Header {
                        Layout.leftMargin: Appearance.layout.gapXl + 4
                        Layout.rightMargin: Appearance.layout.gapXl + 4
                        Layout.bottomMargin: Appearance.layout.gapLg
                    }

                    QuickToggles {
                        Layout.fillWidth: true
                        Layout.leftMargin: Appearance.layout.gapLg
                        Layout.rightMargin: Appearance.layout.gapLg
                        Layout.bottomMargin: Appearance.layout.gapLg
                    }

                    QuickSliders {
                        Layout.fillWidth: true
                        Layout.leftMargin: Appearance.layout.gapLg
                        Layout.rightMargin: Appearance.layout.gapLg
                        Layout.bottomMargin: Appearance.layout.gapLg
                    }

                    NotificationCenter {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: Appearance.layout.gapMd
                        Layout.rightMargin: Appearance.layout.gapMd
                    }

                    NotificationToolbar {
                        Layout.leftMargin: Appearance.layout.gapXl + 4
                        Layout.rightMargin: Appearance.layout.gapXl + 4
                    }
                }
            }

            // Floating dialogs. Each paints its own scrim over the
            // sidebar's interior when active. Multiple instances are
            // mounted concurrently; only one shows at a time.
            WifiMenu      { anchors.fill: parent }
            BluetoothMenu { anchors.fill: parent }
            MicMenu       { anchors.fill: parent }
            VolumeMenu    { anchors.fill: parent }
        }
    }
}
