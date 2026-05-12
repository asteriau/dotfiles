import QtQuick
import qs.modules.sidebar.menus
import qs.modules.common

Item {
    id: root

    Loader {
        anchors.fill: parent
        active: UiState.sidebarMenu === "wifi"
        sourceComponent: WifiMenu {}
    }

    Loader {
        anchors.fill: parent
        active: UiState.sidebarMenu === "bluetooth"
        sourceComponent: BluetoothMenu {}
    }

    Loader {
        anchors.fill: parent
        active: UiState.sidebarMenu === "mic"
        sourceComponent: MicMenu {}
    }

    Loader {
        anchors.fill: parent
        active: UiState.sidebarMenu === "volume"
        sourceComponent: VolumeMenu {}
    }
}
