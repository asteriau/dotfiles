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
    implicitHeight: Math.max(titleColumn.implicitHeight, systemButtonsRow.implicitHeight)

    Component.onCompleted: SystemInfo.subscribe()
    Component.onDestruction: SystemInfo.unsubscribe()

    Column {
        id: titleColumn
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        spacing: Appearance.layout.gapXs

        StyledText {
            text: Qt.formatDateTime(Utils.clock.date, "dddd, MMMM d")
            font.family: Appearance.typography.titleFamily
            font.pixelSize: Appearance.typography.larger
            font.weight: Font.Medium
            color: Appearance.colors.foreground
        }

        StyledText {
            text: "Up " + SystemInfo.uptimeShort
            font.pixelSize: Appearance.typography.smaller
            color: Appearance.colors.m3onSurfaceInactive
        }
    }

    ButtonGroup {
        id: systemButtonsRow
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        color: Appearance.colors.colLayer1
        padding: Appearance.layout.gapSm

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
