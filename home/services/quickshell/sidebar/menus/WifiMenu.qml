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
        Layout.leftMargin: -Appearance.layout.radiusLg
        Layout.rightMargin: -Appearance.layout.radiusLg
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Appearance.layout.radiusLg
        Layout.rightMargin: -Appearance.layout.radiusLg

        ListView {
            anchors.fill: parent
            visible: NetworkState.wifiEnabled && NetworkState.wifiNetworks.length > 0
            clip: true
            spacing: 0
            model: NetworkState.wifiNetworks
            ScrollBar.vertical: ScrollBar {}
            delegate: WifiNetworkRow {
                width: ListView.view.width
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            width: parent.width - 32
            visible: !NetworkState.wifiEnabled
                || (NetworkState.wifiNetworks.length === 0 && !NetworkState.scanning)
            spacing: Appearance.layout.gapSm

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "wifi_off"
                color: Appearance.colors.m3onSurfaceInactive
                font.family: Appearance.typography.iconFamily
                font.pixelSize: 32
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: !NetworkState.wifiEnabled ? "Wi-Fi is off" : "No networks found"
                color: Appearance.colors.m3onSurface
                font.family: Config.typography.family
                font.pixelSize: Appearance.typography.smallie
                wrapMode: Text.Wrap
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: !NetworkState.wifiEnabled
                    ? "Enable it from the toggle, or check your adapter"
                    : "Press Rescan to search again"
                color: Appearance.colors.m3onSurfaceInactive
                font.family: Config.typography.family
                font.pixelSize: Appearance.typography.smaller
                wrapMode: Text.Wrap
            }
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
