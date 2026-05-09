import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.controls
import qs.components.surfaces
import qs.components.text
import qs.services
import qs.utils

SidebarPopup {
    id: root
    active: UiState.sidebarMenu === "volume"
    onDismissed: UiState.sidebarMenu = "none"

    ColumnLayout {
        anchors.fill: parent
        spacing: Config.layout.gapSm

        MenuHeader {
            title: "Volume mixer"
            onBack: UiState.sidebarMenu = "none"
        }

        ListView {
            id: streamList
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: PipeWireState.sinkStreams.length > 0
            clip: true
            spacing: Config.layout.gapSm
            model: PipeWireState.sinkStreams
            ScrollBar.vertical: ScrollBar {}

            delegate: AppVolumeRow {
                width: streamList.width
            }
        }

        Item {
            visible: PipeWireState.sinkStreams.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            MenuEmptyState {
                anchors.centerIn: parent
                width: parent.width
                iconName: "music_off"
                title: "Nothing is playing"
                detail: "Apps will show up here when they output audio"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.topMargin: Config.layout.gapXs
            implicitHeight: 1
            color: Colors.outlineVariant
            opacity: 0.4
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Config.layout.gapSm

            StyledText {
                Layout.fillWidth: true
                variant: StyledText.Variant.Label
                text: "OUTPUT DEVICE"
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
