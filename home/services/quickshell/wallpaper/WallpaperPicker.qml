import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.utils

Loader {
    active: Config.showWallpaperPicker

    sourceComponent: PanelWindow {
        id: picker

        screen: Config.preferredMonitor
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
            onClicked: Config.showWallpaperPicker = false
        }

        WallpaperPickerContent {
            id: content
            anchors.centerIn: parent

            onWallpaperSelected: path => {
                Config.theme.matugen.wallpaper = path;
                Config.showWallpaperPicker = false;
            }
            onClosed: Config.showWallpaperPicker = false
        }
    }
}
