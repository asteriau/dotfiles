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
    show: UiState.sidebarMenu === "wifi"
    onDismiss: UiState.sidebarMenu = "none"

    onShowChanged: {
        if (show) { NetworkState.subscribe(); NetworkState.rescan(); }
        else NetworkState.unsubscribe();
    }

    DialogTitle { text: "Connect to Wi-Fi" }

    DialogSeparator { visible: !NetworkState.scanning }
    DialogProgressBar {
        active: NetworkState.scanning
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Config.layout.radiusLg
        Layout.rightMargin: -Config.layout.radiusLg
    }

    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Config.layout.radiusLg
        Layout.rightMargin: -Config.layout.radiusLg
        clip: true
        spacing: 0
        model: NetworkState.wifiNetworks
        ScrollBar.vertical: ScrollBar {}
        delegate: WifiNetworkRow {
            width: ListView.view.width
        }
    }

    DialogSeparator {}

    DialogButtonRow {
        DialogButton {
            text: "Rescan"
            enabled: NetworkState.wifiEnabled && !NetworkState.scanning
            onClicked: NetworkState.rescan()
        }

        Item { Layout.fillWidth: true }

        DialogButton {
            text: "Done"
            onClicked: root.dismiss()
        }
    }
}
