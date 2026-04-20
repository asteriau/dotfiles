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
        }

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:sidebar:trigger"
        color: "transparent"

        implicitWidth: 6
        implicitHeight: 140

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
        color: Colors.background

        implicitWidth: Config.sidebarWidth

        margins.right: Config.showSidebar ? 0 : -Config.sidebarWidth

        Behavior on margins.right {
            NumberAnimation {
                duration: 360
                easing.type: Easing.OutCubic
            }
        }

        MouseArea {
            id: panelArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: closeTimer.stop()
            onExited: closeTimer.restart()
        }

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
