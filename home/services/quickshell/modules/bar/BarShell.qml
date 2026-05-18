import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.modules.common

// Bar entry point.
//
// Vertical bar  → the original strip window (Bar.qml), behaviourally
//                 unchanged; it simply hides itself when horizontal.
// Horizontal bar → a fullscreen, transparent layer surface whose input/paint
//                 is masked to exactly the bar strip (Phase 1, closed state),
//                 faithful to the reference's HTopLayerPanel. Built from the
//                 same window idiom this shell already uses for the Island and
//                 notification popups (proven not to capture the desktop). The
//                 exclusive zone is reserved by a separate zero-size window so
//                 window tiling stays pixel-identical to before.
Scope {
    id: barShell

    // VERTICAL: untouched original strip window (hidden when horizontal).
    Bar {}

    // HORIZONTAL: reserve the bar's exclusive zone (the host below reserves
    // nothing, exactly as the reference splits these two concerns).
    BarReservedStrip {
        visible: !Config.bar.vertical
    }

    // HORIZONTAL: fullscreen transparent masked host.
    PanelWindow {
        id: host

        visible: !Config.bar.vertical
        screen: UiState.preferredMonitor
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:bar"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // SAFETY-CRITICAL: the mask is also the input region. It is limited to
        // the bar strip only, so every pixel outside it passes through to
        // windows exactly as before. Same proven pattern as Island's
        // `mask: Region { item: container }`.
        mask: Region {
            item: strip
        }

        Item {
            id: strip

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: Config.bar.onEnd ? undefined : parent.top
            anchors.bottom: Config.bar.onEnd ? parent.bottom : undefined
            height: Appearance.bar.height

            BarLayoutHorizontal {
                anchors.fill: parent
            }
        }
    }
}
