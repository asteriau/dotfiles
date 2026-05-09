import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.utils

Loader {
    active: UiState.showWallpaperPicker

    sourceComponent: PanelWindow {
        id: picker

        screen: UiState.preferredMonitor
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell:wallpaperPicker"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        mask: Region {
            item: content
        }

        // Dismiss on click outside content
        MouseArea {
            anchors.fill: parent
            onClicked: UiState.showWallpaperPicker = false
        }

        WallpaperPickerContent {
            id: content
            anchors.centerIn: parent

            onWallpaperSelected: path => {
                Config.theme.matugen.wallpaper = path;
                UiState.showWallpaperPicker = false;
            }
            onClosed: UiState.showWallpaperPicker = false
        }
    }
}
