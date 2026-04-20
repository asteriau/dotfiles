import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Services.Pipewire
import qs.utils

Item {
    id: root
    Layout.fillWidth: true
    implicitHeight: 44

    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btOn: btAdapter?.state === BluetoothAdapterState.Enabled
    readonly property bool micMuted: PipeWireState.defaultSource?.audio?.muted ?? false
    readonly property bool dnd: Config.doNotDisturb

    Rectangle {
        anchors.centerIn: parent
        implicitWidth: row.implicitWidth
        implicitHeight: 44
        radius: height / 2
        color: Colors.elevated

        RowLayout {
            id: row
            anchors.fill: parent
            spacing: 4

            ToggleButton {
                icon: root.wifiOn ? "wifi" : "wifi_off"
                active: root.wifiOn
                onActivated: {
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

    Process { id: wifiProc }
    Process { id: btProc }

    component ToggleButton: Item {
        id: btn
        property string icon
        property bool active
        signal activated

        Layout.preferredWidth: 44
        Layout.preferredHeight: 44

        Rectangle {
            id: pill
            anchors.fill: parent
            radius: width / 2
            color: btn.active ? Colors.accent : (ma.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")
            scale: ma.pressed ? 0.9 : 1.0

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
            font.pixelSize: 18
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
