import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.controls
import qs.components.surfaces
import qs.services
import qs.utils

SidebarPopup {
    id: root
    active: UiState.sidebarMenu === "mic"
    onDismissed: UiState.sidebarMenu = "none"

    ColumnLayout {
        anchors.fill: parent
        spacing: Config.layout.gapSm

        MenuHeader {
            title: "Microphone source"
            onBack: UiState.sidebarMenu = "none"
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: PipeWireState.sources.length > 0
            clip: true
            spacing: Config.layout.gapSm
            model: PipeWireState.sources
            ScrollBar.vertical: ScrollBar {}

            delegate: AudioDeviceRow {
                width: list.width
                isDefault: PipeWireState.defaultSource === modelData
                onSelected: (node) => PipeWireState.setDefaultSource(node)
            }
        }

        Item {
            visible: PipeWireState.sources.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            MenuEmptyState {
                anchors.centerIn: parent
                width: parent.width
                iconName: "mic_off"
                title: "No input devices"
                detail: "Plug in a microphone or check Pipewire"
            }
        }
    }
}
