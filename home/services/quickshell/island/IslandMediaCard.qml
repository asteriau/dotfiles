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

// Bespoke island media card. Dense horizontal layout tuned for ~420x96.
// Lifts art-download / ColorQuantizer / AdaptedMaterialScheme plumbing from
// PlayerControl, but does not reuse that view because its dimensions are
// hardcoded for the sidebar.
Item {
    id: root

    property MprisPlayer player: MprisState.player
    property real radius: 22

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

    component IconBtn: MouseArea {
        id: btnArea
        property string iconName
        property var action
        property bool btnEnabled: true
        width: 28
        height: 28
        cursorShape: btnEnabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true
        enabled: btnEnabled
        opacity: btnEnabled ? (containsMouse ? 1 : 0.85) : 0.35
        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration } }
        onClicked: { if (btnEnabled && action) action() }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: btnArea.containsMouse && btnArea.btnEnabled
                ? ColorMix.transparentize(root.blendedColors.colSecondaryContainer, 0.4)
                : "transparent"
            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: btnArea.iconName
            fill: 1
            font.pointSize: 14
            color: root.blendedColors.colOnLayer0
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
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: 10
            anchors.bottomMargin: 10
            spacing: 12

            // ── Art tile ─────────────────────────────────────────────────
            Rectangle {
                id: artTile
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64
                Layout.alignment: Qt.AlignVCenter
                radius: 12
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
                    sourceSize.width: 192
                    sourceSize.height: 192
                    visible: opacity > 0
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic } }
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    visible: root.displayedArtFilePath.length === 0
                    text: "music_note"
                    fill: 1
                    font.pointSize: 22
                    color: root.blendedColors.colSubtext
                }
            }

            // ── Right column ─────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                MarqueeText {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 22
                    text: (root.player?.trackTitle ?? "") || "Untitled"
                    color: root.blendedColors.colOnLayer0
                    font.family: Config.typography.family
                    font.pixelSize: Config.typography.large
                    font.weight: Font.DemiBold
                    pixelsPerSecond: 35
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.player?.trackArtist ?? ""
                    color: root.blendedColors.colSubtext
                    font.pixelSize: Config.typography.smaller
                    elide: Text.ElideRight
                }

                Item { Layout.fillHeight: true }

                // Progress + controls row
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28

                    Row {
                        id: controls
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        IconBtn {
                            iconName: "skip_previous"
                            btnEnabled: root.player?.canGoPrevious ?? false
                            action: () => root.player?.previous()
                        }
                        IconBtn {
                            iconName: root.player?.isPlaying ? "pause" : "play_arrow"
                            btnEnabled: root.player?.canTogglePlaying ?? true
                            action: () => root.player?.togglePlaying()
                        }
                        IconBtn {
                            iconName: "skip_next"
                            btnEnabled: root.player?.canGoNext ?? false
                            action: () => root.player?.next()
                        }
                    }

                    Item {
                        id: progressArea
                        anchors.left: parent.left
                        anchors.right: controls.left
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        height: 18

                        Rectangle {
                            id: track
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: 3
                            radius: 2
                            color: ColorMix.transparentize(root.blendedColors.colOnLayer0, 0.7)
                        }
                        Rectangle {
                            anchors.left: track.left
                            anchors.verticalCenter: track.verticalCenter
                            height: track.height
                            radius: track.radius
                            width: track.width * root.progressFrac
                            color: root.blendedColors.colPrimary
                        }
                        StyledText {
                            anchors.left: parent.left
                            anchors.bottom: track.top
                            anchors.bottomMargin: 2
                            text: root.fmtTime(root.displayedPosition)
                            font.pixelSize: 10
                            color: root.blendedColors.colSubtext
                        }
                        StyledText {
                            anchors.right: parent.right
                            anchors.bottom: track.top
                            anchors.bottomMargin: 2
                            text: root.fmtTime(root.lengthSec)
                            font.pixelSize: 10
                            color: root.blendedColors.colSubtext
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: e => {
                                if (!root.player || root.lengthSec <= 0) return;
                                const frac = Math.max(0, Math.min(1, e.x / width));
                                root.player.position = frac * root.lengthSec;
                                if (root.browserPlayer) browserPoller.syncPosition(frac * root.lengthSec);
                            }
                        }
                    }
                }
            }
        }
    }
}
