import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.controls
import qs.components.surfaces
import qs.services
import qs.utils

WindowDialog {
    id: root
    backgroundHeight: 460
    show: UiState.sidebarMenu === "mic"
    onDismiss: UiState.sidebarMenu = "none"

    DialogTitle { text: "Audio input" }

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
        model: PipeWireState.sources
        ScrollBar.vertical: ScrollBar {}
        delegate: AudioDeviceRow {
            width: ListView.view.width
            isDefault: PipeWireState.defaultSource && modelData
                && PipeWireState.defaultSource.id === modelData.id
            onSelected: (node) => PipeWireState.setDefaultSource(node)
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
