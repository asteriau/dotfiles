import Quickshell
import Quickshell.Wayland
import qs.modules.common

PanelWindow {
    id: reserved

    screen: UiState.preferredMonitor
    WlrLayershell.namespace: "quickshell:bar-reserved"
    color: "transparent"

    anchors {
        top: !Config.bar.onEnd
        bottom: Config.bar.onEnd
    }
    implicitWidth: 0
    implicitHeight: 0
    exclusiveZone: Appearance.bar.height

    // Empty input region: clicks pass straight through. The exclusiveZone
    // still reserves the strip so windows tile below it as before.
    mask: Region {
        item: null
    }
}
