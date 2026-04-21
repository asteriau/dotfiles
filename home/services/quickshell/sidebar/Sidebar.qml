import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.utils

Scope {
    id: scope

    Timer {
        id: closeTimer
        interval: 400
        onTriggered: {
            if (!triggerArea.containsMouse && !panelArea.containsMouse)
                Config.showSidebar = false;
        }
    }

    PanelWindow {
        id: triggerWin

        screen: Config.preferredMonitor
        visible: !Config.showSidebar

        anchors {
            right: true
            top: true
            bottom: true
        }

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:sidebar:trigger"
        color: "transparent"

        implicitWidth: 6

        MouseArea {
            id: triggerArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                closeTimer.stop();
                Config.showSidebar = true;
            }
            onExited: closeTimer.restart()
        }
    }

    PanelWindow {
        id: sideWin

        screen: Config.preferredMonitor
        visible: true

        anchors {
            right: true
            top: true
            bottom: true
        }

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:sidebar"
        WlrLayershell.keyboardFocus: Config.showSidebar ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        implicitWidth: Config.sidebarWidth

        margins.right: Config.showSidebar ? 0 : -Config.sidebarWidth

        Behavior on margins.right {
            NumberAnimation {
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape)
                Config.showSidebar = false;
        }

        MouseArea {
            id: panelArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: closeTimer.stop()
            onExited: closeTimer.restart()
        }

        Rectangle {
            anchors {
                fill: parent
                margins: 8
            }
            radius: Config.radius
            color: Colors.background
            layer.enabled: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 16

                Profile {}
                QuickToggles {}
                NotificationCenter {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }
                Sliders {}
            }
        }
    }
}
