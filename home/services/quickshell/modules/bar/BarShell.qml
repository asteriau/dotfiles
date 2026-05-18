import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.modules.bar
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
        WlrLayershell.keyboardFocus: BarPopouts.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // SAFETY-CRITICAL: the mask is also the input region.
        //   closed → strip only (Phase-1 pass-through invariant preserved);
        //   open   → strip ∪ popout.
        // The popout sub-region contributes zero area until the popout is
        // on-screen, so nothing outside the bar is captured while closed.
        mask: Region {
            Region {
                item: strip
            }
            Region {
                // Follow the morph shape (it spans bar-pill ∪ popup); the
                // morphPopout frame itself is only pill-sized.
                item: morphPopout.maskItem
                width: morphPopout.visible ? morphPopout.maskItem.width : 0
                height: morphPopout.visible ? morphPopout.maskItem.height : 0
            }
        }

        // Faithful hefty layering, all coincident on the bar-strip rect:
        //   strip (flat background)  ─ below
        //   morphPopout (the morph)  ─ middle  (direct host child → its
        //                              coordinate base is unchanged)
        //   stripContent (widgets)   ─ above   (clock/weather sit ON the
        //                              shape; ActiveWindow never overdrawn)
        Item {
            id: strip

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: Config.bar.onEnd ? undefined : parent.top
            anchors.bottom: Config.bar.onEnd ? parent.bottom : undefined
            height: Appearance.bar.height

            BarBackground {
                anchors.fill: parent
            }
        }

        BarMorphPopout {
            id: morphPopout
        }

        Item {
            id: stripContent

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: Config.bar.onEnd ? undefined : parent.top
            anchors.bottom: Config.bar.onEnd ? parent.bottom : undefined
            height: Appearance.bar.height

            BarLayoutHorizontal {
                anchors.fill: parent
            }
        }

        // Escape closes the open popout. keyboardFocus is OnDemand only while
        // a popout is open (mirrors Island's launcher pattern) and returns to
        // None when closed, so the bar never holds focus at rest (the Phase-1
        // safety invariant is preserved). Closing also works by re-clicking the
        // trigger or opening another popout (BarPopouts is one-at-a-time).
        Shortcut {
            sequences: ["Escape"]
            enabled: BarPopouts.open
            onActivated: BarPopouts.close()
        }

        // Click anywhere outside the bar/popout closes it — the same
        // compositor grab the launcher (Island) uses. Transient: active only
        // while a popout is open and released the instant it closes, so the
        // desktop-passthrough safety invariant is preserved at rest.
        HyprlandFocusGrab {
            windows: [host]
            active: BarPopouts.open
            onCleared: BarPopouts.close()
        }
    }
}
