import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.modules.sidebar.menus
import qs.modules.common

Scope {
    id: scope

    IpcHandler {
        target: "sidebar"
        function toggle(): void { UiState.showSidebar = !UiState.showSidebar; }
        function open(): void { UiState.showSidebar = true; }
        function close(): void { UiState.showSidebar = false; }
    }

    SidebarTrigger {}

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
                duration: Appearance.motion.duration.medium3
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
                if (UiState.sidebarMenu !== "none")
                    UiState.sidebarMenu = "none";
                else
                    UiState.showSidebar = false;
            }
        }

        SidebarChrome {
            anchors.fill: parent

            WifiMenu      { anchors.fill: parent }
            BluetoothMenu { anchors.fill: parent }
            MicMenu       { anchors.fill: parent }
            VolumeMenu    { anchors.fill: parent }
        }
    }
}
