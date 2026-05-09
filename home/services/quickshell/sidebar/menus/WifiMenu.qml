import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.surfaces
import qs.services
import qs.utils

SidebarPopup {
    id: root
    title: "Wi-Fi networks"
    active: UiState.sidebarMenu === "wifi"
    onDismissed: UiState.sidebarMenu = "none"

    Component.onCompleted: { NetworkState.subscribe(); NetworkState.rescan(); }
    Component.onDestruction: NetworkState.unsubscribe()

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        Rectangle {
            id: scanBar
            Layout.fillWidth: true
            implicitHeight: 3
            radius: 1.5
            color: NetworkState.scanning ? "transparent" : Colors.outlineVariant
            opacity: NetworkState.scanning ? 1 : 0.4
            clip: true

            Rectangle {
                visible: NetworkState.scanning
                width: parent.width * 0.3
                height: parent.height
                radius: parent.radius
                color: Colors.colPrimary
                NumberAnimation on x {
                    running: scanBar.visible
                    loops: Animation.Infinite
                    from: -width
                    to: scanBar.width
                    duration: 1100
                }
            }
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 0
            model: NetworkState.wifiNetworks
            ScrollBar.vertical: ScrollBar {}

            delegate: WifiNetworkRow {
                width: list.width
            }
        }

        Text {
            visible: !NetworkState.scanning
                && NetworkState.wifiEnabled
                && NetworkState.wifiNetworks.length === 0
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "No networks found"
            color: Colors.m3onSurfaceInactive
            font.family: "Inter"
            font.pixelSize: 12
        }

        Text {
            visible: !NetworkState.wifiEnabled
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "Wi-Fi is off — enable it from the toggle"
            color: Colors.m3onSurfaceInactive
            font.family: "Inter"
            font.pixelSize: 12
        }
    }
}
