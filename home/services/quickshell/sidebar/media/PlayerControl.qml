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

// Media card orchestrator. Owns all state and non-visual logic; delegates
// visuals to MediaArtBackdrop (shadow + blurred art + tint), MediaProgress
// (seekable slider / progress bar), and MediaControls (prev / play-pause /
// next + time label). The foreground art thumbnail and track text stay here
// because they live in the RowLayout composition slot of the backdrop.
Item {
    id: root
    property MprisPlayer player: null
    property string artUrl: (player?.trackArtUrl ?? "").toString()
    property string artDownloadLocation: StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/quickshell/coverart"
    property string artFileName: Qt.md5(artUrl ?? "")
    property string artFilePath: `${artDownloadLocation}/${artFileName}`
    property color  artDominantColor: ColorMix.mix((colorQuantizer?.colors[0] ?? Colors.accent), Colors.primaryContainer, 0.8)
    property bool   downloaded: false
    property real   radius: Config.layout.mediaCardRadius

    readonly property bool   browserPlayer:      MprisState.isBrowserPlayer(root.player?.dbusName ?? "")
    readonly property string playerctlName:      MprisState.playerctlNameFromDbus(root.player?.dbusName ?? "")
    readonly property bool   artIsRemote:        MprisState.isRemoteArt(root.artUrl)
    readonly property string immediateArtSource: MprisState.resolveArtSource(root.artUrl)

    property string displayedArtFilePath: {
        if (root.artUrl.length === 0)
            return "";
        if (root.immediateArtSource.length > 0)
            return root.immediateArtSource;
        if (root.artIsRemote && root.downloaded)
            return Qt.resolvedUrl(root.artFilePath);
        return "";
    }

    // Derived playback state. For native players we trust the MPRIS signals;
    // for browser players we rely on the poller output.
    readonly property real displayedPosition:
        browserPlayer ? browserPoller.position
                      : clampPosition(player?.position ?? 0)
    readonly property bool progressAnimating:
        browserPlayer ? browserPoller.animating
                      : (player?.playbackState === MprisPlaybackState.Playing)

    property QtObject blendedColors: AdaptedMaterialScheme { color: root.artDominantColor }

    onPlayerChanged: browserPoller.reset()

    onArtUrlChanged: {
        coverArtDownloader.running = false;
        if (root.artUrl.length === 0) {
            root.downloaded = false;
            return;
        }
        if (root.immediateArtSource.length > 0) {
            root.downloaded = true;
            return;
        }

        coverArtDownloader.targetFile = root.artUrl;
        coverArtDownloader.artFilePath = root.artFilePath;
        root.downloaded = false;
        coverArtDownloader.running = true;
    }

    // Ticks the native player's position signal every second so bindings to
    // `player.position` re-evaluate during playback.
    Timer {
        running: !root.browserPlayer && root.player?.playbackState === MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: {
            if (root.player)
                root.player.positionChanged();
        }
    }

    MediaBrowserPoller {
        id: browserPoller
        playerName: root.playerctlName
        active:     root.browserPlayer && root.visible
        maxLength:  root.player?.length ?? 0
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

    MediaArtBackdrop {
        anchors.fill: parent
        radius: root.radius
        artSource: root.displayedArtFilePath
        colors: root.blendedColors

        RowLayout {
            anchors.fill: parent
            anchors.margins: 13
            spacing: 15

            Rectangle {
                id: artBackground
                Layout.fillHeight: true
                implicitWidth: height
                radius: 8
                color: ColorMix.transparentize(root.blendedColors.colLayer1, 0.5)

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: artBackground.width
                        height: artBackground.height
                        radius: artBackground.radius
                    }
                }

                Image {
                    id: mediaArt
                    property int size: parent.height
                    anchors.fill: parent
                    source: root.displayedArtFilePath
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                    antialiasing: true
                    asynchronous: true
                    width: size
                    height: size
                    sourceSize.width: size
                    sourceSize.height: size
                    visible: opacity > 0
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic } }
                }
            }

            ColumnLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    id: trackTitle
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    verticalAlignment: Text.AlignTop
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 20
                    font.pixelSize: Config.typography.large
                    font.weight: Font.DemiBold
                    color: root.blendedColors.colOnLayer0
                    elide: Text.ElideRight
                    text: (root.player?.trackTitle ?? "") || "Untitled"

                    property real animationDistanceX: 6

                    Behavior on text {
                        SequentialAnimation {
                            alwaysRunToEnd: true
                            ParallelAnimation {
                                NumberAnimation { target: trackTitle; property: "x"; to: -trackTitle.animationDistanceX; duration: M3Easing.durationShort3; easing.type: Easing.InSine }
                                NumberAnimation { target: trackTitle; property: "opacity"; to: 0; duration: M3Easing.durationShort3; easing.type: Easing.InSine }
                            }
                            PropertyAction {}
                            PropertyAction { target: trackTitle; property: "x"; value: trackTitle.animationDistanceX }
                            ParallelAnimation {
                                NumberAnimation { target: trackTitle; property: "x"; to: 0; duration: M3Easing.durationShort3; easing.type: Easing.OutSine }
                                NumberAnimation { target: trackTitle; property: "opacity"; to: 1; duration: M3Easing.durationShort3; easing.type: Easing.OutSine }
                            }
                        }
                    }
                }

                StyledText {
                    id: trackArtist
                    Layout.fillWidth: true
                    font.pixelSize: Config.typography.smaller
                    color: root.blendedColors.colSubtext
                    elide: Text.ElideRight
                    text: root.player?.trackArtist ?? ""
                }

                Item { Layout.fillHeight: true }

                MediaControls {
                    Layout.fillWidth: true
                    player: root.player
                    colors: root.blendedColors
                    position: root.displayedPosition
                    length: root.player?.length ?? 0

                    MediaProgress {
                        anchors.fill: parent
                        player: root.player
                        position: root.displayedPosition
                        length: root.player?.length ?? 0
                        animating: root.progressAnimating
                        browserPlayer: root.browserPlayer
                        colors: root.blendedColors
                        onSeekRequested: pos => {
                            if (!root.player)
                                return;
                            root.player.position = pos;
                            if (root.browserPlayer)
                                browserPoller.syncPosition(pos);
                        }
                    }
                }
            }
        }
    }

    function clampPosition(position: real): real {
        const safe = Math.max(0, position ?? 0);
        const length = Math.max(0, root.player?.length ?? 0);
        return length > 0 ? Math.min(safe, length) : safe;
    }
}
