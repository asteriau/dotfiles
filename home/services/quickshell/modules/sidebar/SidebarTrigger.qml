import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common

PanelWindow {
    id: root

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
