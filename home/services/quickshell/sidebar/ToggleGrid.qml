import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Services.Pipewire
import qs.sidebar.controls
import qs.utils
import qs.utils.state

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 14

    readonly property bool wifiOn: Networking.wifiEnabled
    readonly property var btAdapter: Bluetooth.defaultAdapter
    readonly property bool btOn: btAdapter?.state === BluetoothAdapterState.Enabled
    readonly property bool micMuted: PipeWireState.defaultSource?.audio?.muted ?? false

    Process { id: wifiProc }
    Process { id: btProc }

    // ── Pill row (space-between) ──
    RowLayout {
        Layout.fillWidth: true
        spacing: 0

        PillToggle {
            icon: root.wifiOn ? "wifi" : "wifi_off"
            active: root.wifiOn
            onClicked: {
                wifiProc.command = ["nmcli", "radio", "wifi", root.wifiOn ? "off" : "on"];
                wifiProc.running = true;
            }
        }
        Item { Layout.fillWidth: true }
        PillToggle {
            icon: root.btOn ? "bluetooth" : "bluetooth_disabled"
            active: root.btOn
            onClicked: {
                btProc.command = ["bluetoothctl", "power", root.btOn ? "off" : "on"];
                btProc.running = true;
            }
        }
        Item { Layout.fillWidth: true }
        PillToggle {
            icon: Config.doNotDisturb ? "do_not_disturb_on" : "do_not_disturb_off"
            active: Config.doNotDisturb
            onClicked: Config.doNotDisturb = !Config.doNotDisturb
        }
        Item { Layout.fillWidth: true }
        PillToggle {
            icon: root.micMuted ? "mic_off" : "mic"
            active: !root.micMuted
            onClicked: {
                const src = PipeWireState.defaultSource;
                if (src?.audio)
                    src.audio.muted = !src.audio.muted;
            }
        }
    }

    // ── Slider cluster: 4 vertical sliders, space-between ──
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 132
        spacing: 0

        VerticalSlider {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 132
            icon: "brightness_6"
            value: BrightnessState.brightness
            onMoved: v => BrightnessState.setBrightness(v)
        }
        Item { Layout.fillWidth: true }
        VerticalSlider {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 132
            icon: "volume_up"
            value: PipeWireState.defaultSink?.audio?.volume ?? 0
            onMoved: v => {
                const a = PipeWireState.defaultSink?.audio;
                if (a)
                    a.volume = v;
            }
        }
        Item { Layout.fillWidth: true }
        VerticalSlider {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 132
            icon: "music_note"
            value: MprisState.player?.volume ?? 0.5
            onMoved: v => {
                if (MprisState.player)
                    MprisState.player.volume = v;
                OsdState.show("music_note", "Media", v);
            }
        }
        Item { Layout.fillWidth: true }
        VerticalSlider {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 132
            icon: "dark_mode"
            value: NightLightState.tempToSlider(NightLightState.temperature)
            onMoved: v => {
                NightLightState.setTemperature(NightLightState.sliderToTemp(v));
                OsdState.show("dark_mode", "Night Light", v);
            }
        }
    }
}
