import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.sidebar.controls
import qs.services

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: card.implicitHeight

    readonly property bool wifiOn: Network.wifiEnabled
    readonly property bool ethernetConnected: Network.ethernetConnected
    readonly property bool btOn: BluetoothController.enabled
    readonly property bool micMuted: Audio.defaultSource?.audio?.muted ?? false
    readonly property bool dnd: Config.notifications.doNotDisturb

    Component.onCompleted: Network.subscribe()
    Component.onDestruction: Network.unsubscribe()

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        radius: height / 2
        color: Appearance.colors.colLayer1
        antialiasing: true
        implicitWidth: row.implicitWidth + Appearance.layout.gapXl + Appearance.layout.gapMd
        implicitHeight: row.implicitHeight + Appearance.layout.gapLg

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Appearance.layout.gapLg + Appearance.layout.gapXs
            layoutDirection: Qt.LeftToRight

            PillToggle {
                icon: root.ethernetConnected ? "lan" : (root.wifiOn ? "wifi" : "wifi_off")
                active: root.ethernetConnected || root.wifiOn
                enabled: !root.ethernetConnected
                onClicked: {
                    if (root.ethernetConnected) return;
                    Network.setWifiEnabled(!root.wifiOn);
                }
                onRightClicked: UiState.sidebarMenu = "wifi"
            }
            PillToggle {
                icon: root.btOn ? "bluetooth" : "bluetooth_disabled"
                active: root.btOn
                onClicked: BluetoothController.setEnabled(!root.btOn)
                onRightClicked: UiState.sidebarMenu = "bluetooth"
            }
            PillToggle {
                icon: root.dnd ? "do_not_disturb_on" : "do_not_disturb_off"
                active: root.dnd
                onClicked: Config.notifications.doNotDisturb = !Config.notifications.doNotDisturb
            }
            PillToggle {
                icon: root.micMuted ? "mic_off" : "mic"
                active: !root.micMuted
                onClicked: {
                    const src = Audio.defaultSource;
                    if (src?.audio)
                        src.audio.muted = !src.audio.muted;
                }
                onRightClicked: UiState.sidebarMenu = "mic"
            }
        }
    }
}
