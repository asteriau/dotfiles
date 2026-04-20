import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.utils

LazyLoader {
    active: Config.showSidebar

    PanelWindow {
        id: root

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

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 20

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
