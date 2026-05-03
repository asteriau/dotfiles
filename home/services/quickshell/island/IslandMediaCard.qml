pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtCore
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.components.text
import qs.sidebar.media
import qs.utils
import qs.utils.state

// Expanded media card for the island. Targets ~440x112. Art-themed surface via
// MediaArtBackdrop + AdaptedMaterialScheme. Lifts art-download / quantizer
// plumbing from PlayerControl (cannot be reused directly; sidebar geometry).
Item {
    id: root

    property MprisPlayer player: MprisState.player
    property real radius: Config.island.expandRadius

    readonly property string artUrl: (player?.trackArtUrl ?? "").toString()
    readonly property string artDownloadLocation: StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/quickshell/coverart"
    readonly property string artFileName: Qt.md5(artUrl ?? "")
    readonly property string artFilePath: `${artDownloadLocation}/${artFileName}`
    property bool downloaded: false
    property color artDominantColor: ColorMix.mix((colorQuantizer?.colors[0] ?? Colors.accent), Colors.primaryContainer, 0.8)

    readonly property bool browserPlayer:      MprisState.isBrowserPlayer(player?.dbusName ?? "")
    readonly property string playerctlName:    MprisState.playerctlNameFromDbus(player?.dbusName ?? "")
    readonly property bool artIsRemote:        MprisState.isRemoteArt(artUrl)
    readonly property string immediateArtSource: MprisState.resolveArtSource(artUrl)

    readonly property string displayedArtFilePath: {
        if (artUrl.length === 0) return "";
        if (immediateArtSource.length > 0) return immediateArtSource;
        if (artIsRemote && downloaded) return Qt.resolvedUrl(artFilePath);
        return "";
    }

    readonly property real displayedPosition:
        browserPlayer ? browserPoller.position : clampPosition(player?.position ?? 0)
    readonly property bool progressAnimating:
        browserPlayer ? browserPoller.animating : (player?.playbackState === MprisPlaybackState.Playing)
    readonly property real lengthSec: player?.length ?? 0
    readonly property real progressFrac: lengthSec > 0 ? Math.max(0, Math.min(1, displayedPosition / lengthSec)) : 0

    property QtObject blendedColors: AdaptedMaterialScheme { color: root.artDominantColor }

    onPlayerChanged: browserPoller.reset()

    onArtUrlChanged: {
        coverArtDownloader.running = false;
        if (artUrl.length === 0) { downloaded = false; return; }
        if (immediateArtSource.length > 0) { downloaded = true; return; }
        coverArtDownloader.targetFile = artUrl;
        coverArtDownloader.artFilePath = artFilePath;
        downloaded = false;
        coverArtDownloader.running = true;
    }

    Timer {
        running: !root.browserPlayer && root.player?.playbackState === MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: { if (root.player) root.player.positionChanged() }
    }

    MediaBrowserPoller {
        id: browserPoller
        playerName: root.playerctlName
        active: root.browserPlayer && root.visible
        maxLength: root.player?.length ?? 0
    }

    Process {
        id: coverArtDownloader
        property string targetFile: root.artUrl ?? ""
        property string artFilePath: root.artFilePath
        command: [
            "bash", "-c",
            `mkdir -p ${MprisState.shellQuote(root.artDownloadLocation)} && `
            + `{ [ -s ${MprisState.shellQuote(artFilePath)} ] || `
            + `curl -L --fail -sS ${MprisState.shellQuote(targetFile)} -o ${MprisState.shellQuote(artFilePath)}; }`
        ]
        onExited: exitCode => root.downloaded = exitCode === 0
    }

    ColorQuantizer {
        id: colorQuantizer
        source: root.displayedArtFilePath
        depth: 0
        rescaleSize: 1
    }

    function clampPosition(p) {
        const safe = Math.max(0, p ?? 0);
        const len = Math.max(0, root.player?.length ?? 0);
        return len > 0 ? Math.min(safe, len) : safe;
    }

    MediaArtBackdrop {
        anchors.fill: parent
        radius: root.radius
        artSource: root.displayedArtFilePath
        colors: root.blendedColors
        showShadow: false

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 14

            // ── Art tile ─────────────────────────────────────────────────
            Rectangle {
                id: artTile
                Layout.preferredWidth: 80
                Layout.preferredHeight: 80
                Layout.alignment: Qt.AlignVCenter
                radius: 16
                color: ColorMix.transparentize(root.blendedColors.colLayer1, 0.4)
                antialiasing: true

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: artTile.width
                        height: artTile.height
                        radius: artTile.radius
                    }
                }

                Image {
                    anchors.fill: parent
                    source: root.displayedArtFilePath
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                    asynchronous: true
                    antialiasing: true
                    sourceSize.width: 256
                    sourceSize.height: 256
                    visible: opacity > 0
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic } }
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    visible: root.displayedArtFilePath.length === 0
                    text: "music_note"
                    fill: 1
                    pixelSize: 28
                    color: root.blendedColors.colSubtext
                }
            }

            // ── Right column ─────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                MarqueeText {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    text: (root.player?.trackTitle ?? "") || "Untitled"
                    color: root.blendedColors.colOnLayer0
                    font.family: Config.typography.family
                    font.pixelSize: Config.typography.large
                    font.weight: Font.DemiBold
                    pixelsPerSecond: 35
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 16
                    variant: StyledText.Variant.Caption
                    text: root.player?.trackArtist ?? ""
                    color: root.blendedColors.colSubtext
                    elide: Text.ElideRight
                }

                Item { Layout.fillHeight: true }

                MediaControls {
                    Layout.fillWidth: true
                    player: root.player
                    colors: root.blendedColors
                    position: root.displayedPosition
                    length: root.lengthSec

                    MediaProgress {
                        anchors.fill: parent
                        player: root.player
                        position: root.displayedPosition
                        length: root.lengthSec
                        animating: root.progressAnimating
                        browserPlayer: root.browserPlayer
                        colors: root.blendedColors
                        onSeekRequested: pos => {
                            if (!root.player) return;
                            root.player.position = pos;
                            if (root.browserPlayer) browserPoller.syncPosition(pos);
                        }
                    }
                }
            }
        }
    }
}
