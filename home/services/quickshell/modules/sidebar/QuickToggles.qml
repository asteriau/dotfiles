import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

// Four separate circular pill toggles (Wi-Fi, Bluetooth, DND, Mic) inside an
// M3 surface container, sized to wrap the pills (not full-width).
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
        implicitWidth: row.implicitWidth + 24
        implicitHeight: row.implicitHeight + 12

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 14
            layoutDirection: Qt.LeftToRight

            ToggleButton {
                icon: root.ethernetConnected ? "lan" : (root.wifiOn ? "wifi" : "wifi_off")
                active: root.ethernetConnected || root.wifiOn
                enabled: !root.ethernetConnected
                onActivated: {
                    if (root.ethernetConnected) return;
                    Network.setWifiEnabled(!root.wifiOn);
                }
                onRightActivated: UiState.sidebarMenu = "wifi"
            }
            ToggleButton {
                icon: root.btOn ? "bluetooth" : "bluetooth_disabled"
                active: root.btOn
                onActivated: BluetoothController.setEnabled(!root.btOn)
                onRightActivated: UiState.sidebarMenu = "bluetooth"
            }
            ToggleButton {
                icon: root.dnd ? "do_not_disturb_on" : "do_not_disturb_off"
                active: root.dnd
                onActivated: Config.notifications.doNotDisturb = !Config.notifications.doNotDisturb
            }
            ToggleButton {
                icon: root.micMuted ? "mic_off" : "mic"
                active: !root.micMuted
                onActivated: {
                    const src = Audio.defaultSource;
                    if (src?.audio)
                        src.audio.muted = !src.audio.muted;
                }
                onRightActivated: UiState.sidebarMenu = "mic"
            }
        }
    }

    component ToggleButton: Item {
        id: btn
        property string icon
        property bool active
        readonly property int toggleSize: Appearance.layout.pillSize
        signal activated
        signal rightActivated

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: btn.toggleSize
        Layout.preferredHeight: btn.toggleSize
        implicitWidth: btn.toggleSize
        implicitHeight: btn.toggleSize

        Rectangle {
            id: pill
            anchors.fill: parent
            radius: height / 2
            color: btn.active ? Appearance.colors.accent : Appearance.colors.surfaceContainerHighest
            scale: ma.pressed ? 0.92 : 1.0

            Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
        }

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: "Material Symbols Rounded"
            font.pixelSize: Math.round(btn.toggleSize * 0.4)
            color: btn.active ? Appearance.colors.background : Appearance.colors.foreground

            Behavior on color { ColorAnimation { duration: 180 } }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) btn.rightActivated();
                else btn.activated();
            }
        }
    }
}
