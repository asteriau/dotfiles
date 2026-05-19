import QtQuick
import qs.services
import qs.modules.sidebar.quickToggles.models

QuickToggleModel {
    readonly property bool muted: Audio.defaultSink?.audio?.muted ?? false
    name: "Audio output"
    icon: muted ? "volume_off" : "volume_up"
    statusText: muted ? "Muted" : "On"
    tooltipText: "Audio output | Right-click for volume mixer & device selector"
    toggled: !muted
    hasMenu: true
    mainAction: () => {
                    const s = Audio.defaultSink;
                    if (s?.audio)
                    s.audio.muted = !s.audio.muted;
                }
}
