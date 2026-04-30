pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtCore
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.components.controls
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
    function fmtTime(sec) {
        const s = Math.max(0, Math.floor(sec ?? 0));
        const m = Math.floor(s / 60);
        const r = s % 60;
        return m + ":" + (r < 10 ? "0" : "") + r;
    }

    component CtlBtn: RippleButton {
        property string iconName
        property color iconColor: root.blendedColors.colOnLayer0
        implicitWidth: 32
        implicitHeight: 32
        buttonRadius: 999
        colBackground: ColorMix.transparentize(root.blendedColors.colSecondaryContainer, 1)
        colBackgroundHover: ColorMix.transparentize(root.blendedColors.colSecondaryContainerHover, 0.4)
        colRipple: root.blendedColors.colPrimary

        contentItem: MaterialIcon {
            text: parent.iconName
            fill: 1
            pixelSize: 18
            color: parent.iconColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
        }
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

                Item { Layout.fillHeight: true; Layout.fillWidth: true }

                // Progress (wavy slider when seekable)
                MediaProgress {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
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

                // Times + controls row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    spacing: 6

                    StyledText {
                        variant: StyledText.Variant.Label
                        text: root.fmtTime(root.displayedPosition)
                        color: root.blendedColors.colSubtext
                    }
                    Item { Layout.fillWidth: true }

                    CtlBtn {
                        iconName: "skip_previous"
                        enabled: root.player?.canGoPrevious ?? false
                        downAction: () => root.player?.previous()
                    }
                    CtlBtn {
                        iconName: root.player?.isPlaying ? "pause" : "play_arrow"
                        enabled: root.player?.canTogglePlaying ?? true
                        colBackground: ColorMix.transparentize(root.blendedColors.colPrimary, 0.15)
                        colBackgroundHover: root.blendedColors.colPrimary
                        iconColor: root.blendedColors.colOnPrimary
                        downAction: () => root.player?.togglePlaying()
                    }
                    CtlBtn {
                        iconName: "skip_next"
                        enabled: root.player?.canGoNext ?? false
                        downAction: () => root.player?.next()
                    }

                    Item { Layout.fillWidth: true }
                    StyledText {
                        variant: StyledText.Variant.Label
                        text: root.fmtTime(root.lengthSec)
                        color: root.blendedColors.colSubtext
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
