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

    // Broader than isNativeBrowser: also covers plasma-browser-integration.
    // Used to trigger playerctl polling for browser-origin players that don't
    // emit position updates natively over the DBus MPRIS interface.
    function isBrowserPlayer(name: string): bool {
        return isNativeBrowser(name)
            || name.startsWith("org.mpris.MediaPlayer2.plasma-browser-integration");
    }

    function playerctlNameFromDbus(name: string): string {
        const prefix = "org.mpris.MediaPlayer2.";
        return name.startsWith(prefix) ? name.slice(prefix.length) : name;
    }

    // MPRIS art-url helpers. Live here so any player UI can resolve art the
    // same way (local path, file://, or remote URL).
    function isRemoteArt(url: string): bool {
        return url.startsWith("http://") || url.startsWith("https://");
    }

    function resolveArtSource(url: string): string {
        if (isRemoteArt(url))
            return url;
        if (url.startsWith("file://"))
            return url;
        if (url.startsWith("/"))
            return Qt.resolvedUrl(url);
        return url;
    }

    // POSIX-safe single-quoting for shell command construction.
    function shellQuote(value: string): string {
        return "'" + String(value ?? "").replace(/'/g, "'\"'\"'") + "'";
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
