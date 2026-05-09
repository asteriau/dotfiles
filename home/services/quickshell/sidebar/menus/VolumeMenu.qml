import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.controls
import qs.components.surfaces
import qs.services
import qs.utils

SidebarPopup {
    id: root
    title: "Volume mixer"
    active: UiState.sidebarMenu === "volume"
    onDismissed: UiState.sidebarMenu = "none"

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colors.outlineVariant
            opacity: 0.4
        }

        ListView {
            id: streamList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: PipeWireState.sinkStreams
            ScrollBar.vertical: ScrollBar {}

            delegate: AppVolumeRow {
                width: streamList.width
            }
        }

        Text {
            visible: PipeWireState.sinkStreams.length === 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "Nothing is playing"
            color: Colors.m3onSurfaceInactive
            font.family: "Inter"
            font.pixelSize: 12
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Colors.outlineVariant
            opacity: 0.4
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: "Output device"
                color: Colors.m3onSurfaceVariant
                font.family: "Inter"
                font.pixelSize: 11
                font.weight: Font.Medium
            }

            StyledComboBox {
                id: sinkBox
                Layout.fillWidth: true
                model: PipeWireState.sinks
                displayRole: "description"
                currentIndex: {
                    const def = PipeWireState.defaultSink;
                    if (!def) return -1;
                    return PipeWireState.sinks.findIndex(n => n === def);
                }
                onActivated: (idx) => {
                    const node = PipeWireState.sinks[idx];
                    if (node) PipeWireState.setDefaultSink(node);
                }
            }
        }
    }
}
