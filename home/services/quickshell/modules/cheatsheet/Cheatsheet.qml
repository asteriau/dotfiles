import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    Loader {
        id: cheatsheetLoader
        active: false

        sourceComponent: PanelWindow {
            id: cheatsheetRoot
            visible: cheatsheetLoader.active

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // The exit animation must finish before the Loader tears the
            // window down, so hide() flips `closing` and defers deactivation
            // by exitTimer (one animation duration).
            property bool appeared: false
            property bool closing: false
            readonly property bool shown: appeared && !closing

            function hide() {
                if (closing)
                    return;
                closing = true;
                exitTimer.start();
            }

            Component.onCompleted: appeared = true

            exclusiveZone: 0
            implicitWidth: cheatsheetBackground.width + Appearance.spacing.sm * 2
            implicitHeight: cheatsheetBackground.height + Appearance.spacing.sm * 2
            WlrLayershell.namespace: "quickshell:cheatsheet"
            WlrLayershell.keyboardFocus: cheatsheetLoader.active ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            color: "transparent"

            mask: Region {
                item: cheatsheetBackground
            }

            Timer {
                id: exitTimer
                interval: Appearance.motion.duration.medium3
                onTriggered: cheatsheetLoader.active = false
            }

            HyprlandFocusGrab {
                windows: [cheatsheetRoot]
                active: cheatsheetLoader.active
                onCleared: cheatsheetRoot.hide()
            }

            // Shadow and dialog share one transform so they fade and scale
            // together — animating only the dialog left the shadow lingering
            // for the exit duration.
            Item {
                id: dialogWrap
                anchors.centerIn: parent
                implicitWidth: cheatsheetBackground.implicitWidth
                implicitHeight: cheatsheetBackground.implicitHeight

                transformOrigin: Item.Center
                scale: cheatsheetRoot.shown ? 1.0 : 0.92
                opacity: cheatsheetRoot.shown ? 1.0 : 0.0
                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.motion.duration.medium3
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.emphasized
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.motion.duration.medium3
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.emphasized
                    }
                }

                CheatsheetShadow {
                    target: cheatsheetBackground
                }
                Rectangle {
                    id: cheatsheetBackground
                    anchors.centerIn: parent

                    color: Appearance.colors.background
                    radius: Appearance.radius.xl
                    property real padding: Appearance.spacing.xl
                    implicitWidth: cheatsheetContent.implicitWidth + padding * 2
                    implicitHeight: cheatsheetContent.implicitHeight + padding * 2

                    CheatsheetKeybinds {
                        id: cheatsheetContent
                        anchors.centerIn: parent
                        onCloseRequested: cheatsheetRoot.hide()
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "cheatsheet"

        function toggle(): void {
            cheatsheetLoader.active = !cheatsheetLoader.active;
        }

        function close(): void {
            cheatsheetLoader.active = false;
        }

        function open(): void {
            cheatsheetLoader.active = true;
        }
    }
}
