import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.controls
import qs.components.surfaces
import qs.services
import qs.utils

SidebarPopup {
    id: root
    active: UiState.sidebarMenu === "wifi"
    onDismissed: UiState.sidebarMenu = "none"

    Component.onCompleted: { NetworkState.subscribe(); NetworkState.rescan(); }
    Component.onDestruction: NetworkState.unsubscribe()

    ColumnLayout {
        anchors.fill: parent
        spacing: Config.layout.gapSm

        MenuHeader {
            title: "Wi-Fi networks"
            trailingIcon: NetworkState.wifiEnabled ? "refresh" : ""
            onBack: UiState.sidebarMenu = "none"
            onTrailingClicked: NetworkState.rescan()
        }

        MenuIndeterminateBar {
            Layout.fillWidth: true
            active: NetworkState.scanning
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: NetworkState.wifiEnabled && NetworkState.wifiNetworks.length > 0
            clip: true
            spacing: Config.layout.gapSm
            model: NetworkState.wifiNetworks
            ScrollBar.vertical: ScrollBar {}

            delegate: WifiNetworkRow {
                width: list.width
            }
        }

        Item {
            visible: NetworkState.wifiEnabled
                && !NetworkState.scanning
                && NetworkState.wifiNetworks.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true

            MenuEmptyState {
                anchors.centerIn: parent
                width: parent.width
                iconName: "wifi_off"
                title: "No networks found"
                detail: "Pull refresh to scan again"
            }
        }

        Item {
            visible: !NetworkState.wifiEnabled
            Layout.fillWidth: true
            Layout.fillHeight: true

            MenuEmptyState {
                anchors.centerIn: parent
                width: parent.width
                iconName: "wifi_off"
                title: "Wi-Fi is off"
                detail: "Enable it from the toggle"
            }
        }
    }
}
