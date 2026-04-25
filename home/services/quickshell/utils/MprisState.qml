pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property bool hasActivePlasmaIntegration: Mpris.players.values.some(
        p => (p?.dbusName ?? "").startsWith("org.mpris.MediaPlayer2.plasma-browser-integration")
    )
    readonly property var players: Mpris.players.values.filter(player => isUsable(player))
    property MprisPlayer trackedPlayer: null
    readonly property MprisPlayer player: trackedPlayer ?? players[0] ?? null

    function isNativeBrowser(name: string): bool {
        return name.startsWith("org.mpris.MediaPlayer2.firefox")
            || name.startsWith("org.mpris.MediaPlayer2.chromium")
            || name.startsWith("org.mpris.MediaPlayer2.chrome")
            || name.startsWith("org.mpris.MediaPlayer2.brave")
            || name.startsWith("org.mpris.MediaPlayer2.zen");
    }

    function isUsable(player: MprisPlayer): bool {
        const name = player?.dbusName ?? "";
        return !(
            (root.hasActivePlasmaIntegration && root.isNativeBrowser(name))
            || name.startsWith("org.mpris.MediaPlayer2.playerctld")
            || (name.endsWith(".mpd") && !name.endsWith("MediaPlayer2.mpd"))
        );
    }

    Instantiator {
        model: Mpris.players

        Connections {
            required property MprisPlayer modelData
            target: modelData

            Component.onCompleted: {
                if (!root.isUsable(modelData))
                    return;
                if (root.trackedPlayer == null || modelData.isPlaying)
                    root.trackedPlayer = modelData;
            }

            Component.onDestruction: {
                if (root.trackedPlayer !== modelData)
                    return;

                root.trackedPlayer = null;
                for (const player of root.players) {
                    if (player.playbackState === MprisPlaybackState.Playing || player.isPlaying) {
                        root.trackedPlayer = player;
                        break;
                    }
                }

                if (root.trackedPlayer == null)
                    root.trackedPlayer = root.players[0] ?? null;
            }

            function onPlaybackStateChanged() {
                if (!root.isUsable(modelData))
                    return;
                if (root.trackedPlayer !== modelData)
                    root.trackedPlayer = modelData;
            }
        }
    }

    IpcHandler {
        target: "mpris"

        function pauseAll() {
            for (const p of Mpris.players.values)
                if (p.canPause)
                    p.pause();
        }

        function togglePlaying() {
            const p = root.player;
            if (p && p.canTogglePlaying)
                p.togglePlaying();
        }

        function previous() {
            const p = root.player;
            if (p && p.canGoPrevious)
                p.previous();
        }

        function next() {
            const p = root.player;
            if (p && p.canGoNext)
                p.next();
        }
    }
}
