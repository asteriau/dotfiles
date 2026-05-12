import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.controls
import qs.components.surfaces
import qs.services
import qs.utils

WindowDialog {
    id: root
    backgroundHeight: 600
    show: UiState.sidebarMenu === "volume"
    onDismiss: UiState.sidebarMenu = "none"

    DialogTitle { text: "Audio output" }

    DialogSeparator {
        Layout.topMargin: -22
        Layout.leftMargin: 0
        Layout.rightMargin: 0
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: -22
        Layout.bottomMargin: -16
        Layout.leftMargin: -Appearance.layout.radiusLg
        Layout.rightMargin: -Appearance.layout.radiusLg
        topMargin: 12
        bottomMargin: 12
        clip: true
        spacing: 4
        model: PipeWireState.sinkStreams
        ScrollBar.vertical: ScrollBar {}
        delegate: AppVolumeRow {
            width: ListView.view.width
        }
    }

    DialogSeparator {}

    // Output device picker — matches mic menu's row list, no combobox.
    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: -Appearance.layout.radiusLg
        Layout.rightMargin: -Appearance.layout.radiusLg
        spacing: 0

        Repeater {
            model: PipeWireState.sinks
            delegate: AudioDeviceRow {
                isDefault: PipeWireState.defaultSink && modelData
                    && PipeWireState.defaultSink.id === modelData.id
                onSelected: (node) => PipeWireState.setDefaultSink(node)
            }
        }
    }

    DialogButtonRow {
        Item { Layout.fillWidth: true }
        DialogButton {
            text: "Done"
            onClicked: root.dismiss()
        }
    }
}
