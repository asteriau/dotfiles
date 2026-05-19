import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import qs.modules.sidebar.quickToggles
import qs.modules.sidebar.quickToggles.classicStyle

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: Math.max(uptimeContainer.implicitHeight, systemButtonsRow.implicitHeight)

    Component.onCompleted: SystemInfo.subscribe()
    Component.onDestruction: SystemInfo.unsubscribe()

    Rectangle {
        id: uptimeContainer
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        color: Appearance.colors.colLayer1
        radius: height / 2
        implicitWidth: uptimeRow.implicitWidth + 24
        implicitHeight: uptimeRow.implicitHeight + 8

        Row {
            id: uptimeRow
            anchors.centerIn: parent
            spacing: 8

            CustomIcon {
                id: distroIcon
                anchors.verticalCenter: parent.verticalCenter
                width: 25
                height: 25
                source: SystemInfo.distroIcon
                colorize: true
                color: Appearance.colors.colOnLayer0
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Appearance.typography.normal
                color: Appearance.colors.colOnLayer0
                text: "Up " + SystemInfo.uptimeShort
                textFormat: Text.MarkdownText
            }
        }
    }

    ButtonGroup {
        id: systemButtonsRow
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        color: Appearance.colors.colLayer1
        padding: 4

        SystemQuickToggleButton {
            toggled: UiState.quickTogglesEditMode
            buttonIcon: "edit"
            tooltipText: "Edit quick toggles" + (UiState.quickTogglesEditMode
                                                 ? "\nLMB to enable/disable\nRMB to toggle size\nScroll to swap position" :
                                                   "")
            onClicked: UiState.quickTogglesEditMode = !UiState.quickTogglesEditMode
        }
        SystemQuickToggleButton {
            toggled: false
            buttonIcon: "restart_alt"
            tooltipText: "Reload Hyprland & Quickshell"
            onClicked: {
                Quickshell.execDetached(["hyprctl", "reload"]);
                Quickshell.reload(true);
            }
        }
        SystemQuickToggleButton {
            toggled: false
            buttonIcon: "settings"
            tooltipText: "Settings"
            onClicked: Utils.launchSettings()
        }
    }
}
