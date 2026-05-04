import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import qs.utils
import qs.utils.state

// Four separate circular pill toggles (Wi-Fi, Bluetooth, DND, Mic) inside an
// M3 surface container, sized to wrap the pills (not full-width).
Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: card.implicitHeight

    readonly property bool wifiOn: Networking.wifiEnabled
    property bool ethernetConnected: false
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btOn: btAdapter?.state === BluetoothAdapterState.Enabled
    readonly property bool micMuted: PipeWireState.defaultSource?.audio?.muted ?? false
    readonly property bool dnd: Config.doNotDisturb

    Process { id: wifiProc }
    Process { id: btProc }

    // Poll ethernet connectivity via nmcli — Networking.devices type strings
    // aren't reliable across Quickshell versions.
    Process {
        id: ethProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE", "device"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.ethernetConnected = text.split("\n").some(l => {
                    const [type, state] = l.split(":");
                    return type === "ethernet" && state === "connected";
                });
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: ethProc.running = true
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        radius: height / 2
        color: Colors.colLayer1
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
                    wifiProc.command = ["nmcli", "radio", "wifi", root.wifiOn ? "off" : "on"];
                    wifiProc.running = true;
                }
            }
            ToggleButton {
                icon: root.btOn ? "bluetooth" : "bluetooth_disabled"
                active: root.btOn
                onActivated: {
                    btProc.command = ["bluetoothctl", "power", root.btOn ? "off" : "on"];
                    btProc.running = true;
                }
            }
            ToggleButton {
                icon: root.dnd ? "do_not_disturb_on" : "do_not_disturb_off"
                active: root.dnd
                onActivated: Config.doNotDisturb = !Config.doNotDisturb
            }
            ToggleButton {
                icon: root.micMuted ? "mic_off" : "mic"
                active: !root.micMuted
                onActivated: {
                    const src = PipeWireState.defaultSource;
                    if (src?.audio)
                        src.audio.muted = !src.audio.muted;
                }
            }
        }
    }

    component ToggleButton: Item {
        id: btn
        property string icon
        property bool active
        readonly property int toggleSize: Config.layout.pillSize
        signal activated

        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: btn.toggleSize
        Layout.preferredHeight: btn.toggleSize
        implicitWidth: btn.toggleSize
        implicitHeight: btn.toggleSize

        Rectangle {
            id: pill
            anchors.fill: parent
            radius: height / 2
            color: btn.active ? Colors.accent : Colors.surfaceContainerHighest
            scale: ma.pressed ? 0.92 : 1.0

            Behavior on color {
                ColorAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutQuad
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: "Material Symbols Rounded"
            font.pixelSize: Math.round(btn.toggleSize * 0.4)
            color: btn.active ? Colors.background : Colors.foreground

            Behavior on color {
                ColorAnimation {
                    duration: 180
                }
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }
    }
}
