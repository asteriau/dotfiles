import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.surfaces
import qs.services
import qs.utils

SidebarPopup {
    id: root
    title: "Microphone source"
    active: UiState.sidebarMenu === "mic"
    onDismissed: UiState.sidebarMenu = "none"

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colors.outlineVariant
            opacity: 0.4
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 0
            model: PipeWireState.sources
            ScrollBar.vertical: ScrollBar {}

            delegate: AudioDeviceRow {
                width: list.width
                isDefault: PipeWireState.defaultSource === modelData
                onSelected: (node) => PipeWireState.setDefaultSource(node)
            }
        }

        Text {
            visible: PipeWireState.sources.length === 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "No input devices found"
            color: Colors.m3onSurfaceInactive
            font.family: "Inter"
            font.pixelSize: 12
        }
    }
}
