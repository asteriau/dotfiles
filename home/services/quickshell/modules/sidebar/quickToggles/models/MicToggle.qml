import QtQuick
import qs.services
import qs.modules.sidebar.quickToggles.models

QuickToggleModel {
    readonly property bool muted: Audio.defaultSource?.audio?.muted ?? false
    name: "Microphone"
    icon: muted ? "mic_off" : "mic"
    statusText: muted ? "Muted" : "On"
    tooltipText: "Microphone | Right-click for volume mixer & device selector"
    toggled: !muted
    hasMenu: true
    mainAction: () => {
                    const s = Audio.defaultSource;
                    if (s?.audio)
                    s.audio.muted = !s.audio.muted;
                }
}
