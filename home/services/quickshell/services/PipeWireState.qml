pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root
    property PwNode defaultSink: Pipewire.defaultAudioSink
    property PwNode defaultSource: Pipewire.defaultAudioSource

    readonly property var sinks: Pipewire.nodes.values.filter(n => n && !n.isStream && n.isSink === true && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => n && !n.isStream && n.isSink === false && n.audio)
    readonly property var sinkStreams: Pipewire.nodes.values.filter(n => n && n.isStream && n.isSink === true && n.audio)

    function setDefaultSink(node): void {
        if (node) Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultSource(node): void {
        if (node) Pipewire.preferredDefaultAudioSource = node;
    }

    PwObjectTracker {
        objects: {
            const list = [];
            if (root.defaultSink)   list.push(root.defaultSink);
            if (root.defaultSource) list.push(root.defaultSource);
            root.sinks.forEach(n => list.push(n));
            root.sources.forEach(n => list.push(n));
            root.sinkStreams.forEach(n => list.push(n));
            return list;
        }
    }

    function sinkIcon() {
      const audio = root.defaultSink?.audio;
      if (audio.muted)
        return "audio-volume-muted-symbolic";

      const vol = audio.volume * 100;
      const icon = [
        [101, "audio-volume-overamplified-symbolic"],
        [67, "audio-volume-high-symbolic"],
        [34, "audio-volume-medium-symbolic"],
        [1, "audio-volume-low-symbolic"],
        [0, "audio-volume-muted-symbolic"],
      ].find(([threshold]) => threshold <= vol)[1];

      return icon;
    }

    function sourceIcon() {
      const audio = root.defaultSource?.audio;
      if (audio.muted)
        return "microphone-sensitivity-muted-symbolic";

      const vol = audio.volume * 100;
      const icon = [
        [67, "microphone-sensitivity-high-symbolic"],
        [34, "microphone-sensitivity-medium-symbolic"],
        [1, "microphone-sensitivity-low-symbolic"],
        [0, "microphone-sensitivity-muted-symbolic"],
      ].find(([threshold]) => threshold <= vol)[1];

      return icon;
    }
}
