import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

Item {
    id: root

    property string icon: "volume_up"
    property string label: ""
    property real   progress: 0
    property bool   active: false

    // Seeded change-detection — upstream services emit spurious refreshes on
    // session start; ignore the first event of each source.
    property real _lastSinkVol: -1
    property bool _lastSinkMuted: false
    property bool _seededSink: false
    property real _lastSourceVol: -1
    property bool _lastSourceMuted: false
    property bool _seededSource: false

    Timer {
        id: hideTimer
        interval: Config.osd.timeoutMs
        onTriggered: root.active = false
    }

    Connections {
        target: Audio.defaultSink ? Audio.defaultSink.audio : null
        function update() {
            const muted = Audio.defaultSink?.audio.muted ?? false;
            const vol   = Audio.defaultSink?.audio.volume ?? 0;
            const changed = !root._seededSink
                || muted !== root._lastSinkMuted
                || Math.abs(vol - root._lastSinkVol) > 0.0005;
            root._lastSinkVol   = vol;
            root._lastSinkMuted = muted;
            if (!root._seededSink) { root._seededSink = true; return; }
            if (!changed) return;
            root.icon = muted ? "volume_off"
                : (vol < 0.01 ? "volume_mute"
                : (vol < 0.5 ? "volume_down" : "volume_up"));
            root.label = "Volume";
            root.progress = vol;
            root.active = true;
            hideTimer.restart();
        }
        function onVolumeChanged() { update() }
        function onMutedChanged()  { update() }
    }

    Connections {
        target: Audio.defaultSource ? Audio.defaultSource.audio : null
        function update() {
            const muted = Audio.defaultSource?.audio.muted ?? false;
            const vol   = Audio.defaultSource?.audio.volume ?? 0;
            const changed = !root._seededSource
                || muted !== root._lastSourceMuted
                || Math.abs(vol - root._lastSourceVol) > 0.0005;
            root._lastSourceVol   = vol;
            root._lastSourceMuted = muted;
            if (!root._seededSource) { root._seededSource = true; return; }
            if (!changed) return;
            root.icon = muted ? "mic_off" : "mic";
            root.label = "Microphone";
            root.progress = vol;
            root.active = true;
            hideTimer.restart();
        }
        function onVolumeChanged() { update() }
        function onMutedChanged()  { update() }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged() {
            root.icon = "brightness_medium";
            root.label = "Brightness";
            root.progress = Brightness.brightness ?? 0;
            root.active = true;
            hideTimer.restart();
        }
    }

    Connections {
        target: Osd
        function onShow(icon, label, progress) {
            root.icon = icon;
            root.label = label;
            root.progress = progress;
            root.active = true;
            hideTimer.restart();
        }
    }
}
