import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root
    // The IPC handler and shortcuts drive this; never write
    // cheatsheetLoader.active directly, that would break the gate binding.
    property bool open: false

    RevealGate {
        id: gate
        shown: root.open
    }

    Loader {
        id: cheatsheetLoader
        active: gate.active

        sourceComponent: PanelWindow {
            id: cheatsheetRoot
            visible: true

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            function hide() {
                root.open = false;
            }

            exclusiveZone: 0
            implicitWidth: cheatsheetBackground.width + Appearance.sizes.elevationMargin * 2
            implicitHeight: cheatsheetBackground.height + Appearance.sizes.elevationMargin * 2
            WlrLayershell.namespace: "quickshell:cheatsheet"
            WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            color: "transparent"

            mask: Region {
                item: cheatsheetBackground
            }

            Component.onCompleted: {
                GlobalFocusGrab.addDismissable(cheatsheetRoot);
            }
            Component.onDestruction: {
                GlobalFocusGrab.removeDismissable(cheatsheetRoot);
            }
            Connections {
                target: GlobalFocusGrab
                function onDismissed() {
                    cheatsheetRoot.hide();
                }
            }

            // Shadow and dialog share one surface so they fade and scale together
            RevealSurface {
                anchors.fill: parent
                shown: root.open
                transformOrigin: Item.Center

                StyledRectangularShadow {
                    target: cheatsheetBackground
                }
                Rectangle {
                    id: cheatsheetBackground
                    anchors.centerIn: parent
                    color: Appearance.colors.colLayer0
                    border.width: 1
                    border.color: Appearance.colors.colLayer0Border
                    radius: Appearance.rounding.windowRounding
                    property real padding: 24
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
            root.open = !root.open;
        }

        function close(): void {
            root.open = false;
        }

        function open(): void {
            root.open = true;
        }
    }

    GlobalShortcut {
        name: "cheatsheetToggle"
        description: "Toggles cheatsheet on press"

        onPressed: {
            root.open = !root.open;
        }
    }

    GlobalShortcut {
        name: "cheatsheetOpen"
        description: "Opens cheatsheet on press"

        onPressed: {
            root.open = true;
        }
    }

    GlobalShortcut {
        name: "cheatsheetClose"
        description: "Closes cheatsheet on press"

        onPressed: {
            root.open = false;
        }
    }
}
