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
        Layout.leftMargin: -Config.layout.radiusLg
        Layout.rightMargin: -Config.layout.radiusLg
        topMargin: 12
        bottomMargin: 12
        leftMargin: 20
        rightMargin: 20
        clip: true
        spacing: 4
        model: PipeWireState.sinkStreams
        ScrollBar.vertical: ScrollBar {}
        delegate: AppVolumeRow {
            width: ListView.view.width
        }
    }

    StyledComboBox {
        id: sinkBox
        Layout.fillWidth: true
        Layout.bottomMargin: 6
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

    DialogButtonRow {
        Item { Layout.fillWidth: true }
        DialogButton {
            text: "Done"
            onClicked: root.dismiss()
        }
    }
}
