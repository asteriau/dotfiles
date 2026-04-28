import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.utils

Variants {
    id: root
    model: Quickshell.screens

    PanelWindow {
        id: bgWindow
        required property var modelData

        screen: modelData
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Bottom
        WlrLayershell.namespace: "quickshell:background"
        color: "transparent"

        visible: Config.theme.matugen.wallpaper.length > 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        Image {
            anchors.fill: parent
            source: Config.theme.matugen.wallpaper.length > 0
                    ? ("file://" + Config.theme.matugen.wallpaper)
                    : ""
            fillMode: Image.PreserveAspectCrop
            cache: false
            smooth: true
            asynchronous: true
        }
    }
}
