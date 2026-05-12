import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common

PanelWindow {
    id: barWindow
    WlrLayershell.namespace: "quickshell:bar"
    screen: UiState.preferredMonitor

    anchors {
        top:    Config.bar.vertical || !Config.bar.onEnd
        bottom: Config.bar.vertical || Config.bar.onEnd
        left:   !Config.bar.vertical || !Config.bar.onEnd
        right:  !Config.bar.vertical || Config.bar.onEnd
    }
    implicitWidth:  Config.bar.vertical ? Appearance.bar.width  : 0
    implicitHeight: Config.bar.vertical ? 0 : Appearance.bar.height

    color: "transparent"

    Loader {
        anchors.fill: parent
        sourceComponent: Config.bar.vertical ? verticalLayout : horizontalLayout
    }

    Component { id: verticalLayout;   BarLayoutVertical {} }
    Component { id: horizontalLayout; BarLayoutHorizontal {} }
}
