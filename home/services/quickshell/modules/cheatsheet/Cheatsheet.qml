import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
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

            function hide() {
                cheatsheetLoader.active = false;
            }
            exclusiveZone: 0
            implicitWidth: cheatsheetBackground.width + Appearance.spacing.sm * 2
            implicitHeight: cheatsheetBackground.height + Appearance.spacing.sm * 2
            WlrLayershell.namespace: "quickshell:cheatsheet"
            WlrLayershell.keyboardFocus: cheatsheetLoader.active ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
            color: "transparent"

            mask: Region {
                item: cheatsheetBackground
            }

            HyprlandFocusGrab {
                windows: [cheatsheetRoot]
                active: cheatsheetLoader.active
                onCleared: cheatsheetRoot.hide()
            }

            CheatsheetShadow {
                target: cheatsheetBackground
            }
            Rectangle {
                id: cheatsheetBackground
                anchors.centerIn: parent
                color: Appearance.colors.colLayer0
                border.width: 1
                border.color: ColorUtils.mix(Appearance.colors.colOutlineVariant, Appearance.colors.colLayer0, 0.4)
                radius: Appearance.radius.lg
                property real padding: 20
                implicitWidth: cheatsheetColumnLayout.implicitWidth + padding * 2
                implicitHeight: cheatsheetColumnLayout.implicitHeight + padding * 2

                focus: cheatsheetRoot.visible
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        cheatsheetRoot.hide();
                        event.accepted = true;
                    }
                }

                RippleButton {
                    id: closeButton
                    implicitWidth: 40
                    implicitHeight: 40
                    buttonRadius: Appearance.radius.full
                    anchors {
                        top: parent.top
                        right: parent.right
                        topMargin: 20
                        rightMargin: 20
                    }
                    onClicked: cheatsheetRoot.hide()
                    contentItem: MaterialIcon {
                        anchors.centerIn: parent
                        horizontalAlignment: Text.AlignHCenter
                        pixelSize: Appearance.typography.title
                        text: "close"
                    }
                }

                ColumnLayout {
                    id: cheatsheetColumnLayout
                    anchors.centerIn: parent
                    spacing: 10

                    CheatsheetKeybinds {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
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
