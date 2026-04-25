pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.components
import qs.utils

Item {
    id: root
    property MprisPlayer player: null
    property string artUrl: (player?.trackArtUrl ?? "").toString()
    property string artDownloadLocation: StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/quickshell/coverart"
    property string artFileName: Qt.md5(artUrl ?? "")
    property string artFilePath: `${artDownloadLocation}/${artFileName}`
    property color artDominantColor: ColorMix.mix((colorQuantizer?.colors[0] ?? Colors.accent), Colors.primaryContainer, 0.8)
    property bool downloaded: false
    property real radius: 22
    property real displayedPosition: 0
    property bool progressAnimating: false
    property string polledStatus: "Stopped"
    property real polledPosition: 0
    property real lastPolledPosition: 0
    property bool hasPollSample: false
    property int stalledPolls: 0
    readonly property bool browserPlayer: root.isBrowserPlayer(root.player?.dbusName ?? "")
    readonly property string playerctlName: root.playerctlNameFromDbus(root.player?.dbusName ?? "")
    readonly property bool artIsRemote: root.isRemoteArt(root.artUrl)
    readonly property string immediateArtSource: root.resolveArtSource(root.artUrl)

    property string displayedArtFilePath: {
        if (root.artUrl.length === 0)
            return "";
        if (root.immediateArtSource.length > 0)
            return root.immediateArtSource;
        if (root.artIsRemote && root.downloaded)
            return Qt.resolvedUrl(root.artFilePath);
        return "";
    }

    property QtObject blendedColors: AdaptedMaterialScheme { color: root.artDominantColor }

    onPlayerChanged: root.resetProgressState()

    Component.onCompleted: root.resetProgressState()

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

    Connections {
        target: root.player
        ignoreUnknownSignals: true

        function onPlaybackStateChanged() {
            root.syncDisplayedPosition();
        }

        function onPositionChanged() {
            root.syncDisplayedPosition();
        }

        function onLengthChanged() {
            root.syncDisplayedPosition();
        }

        function onTrackTitleChanged() {
            root.syncDisplayedPosition();
        }

        function onTrackArtistChanged() {
            root.syncDisplayedPosition();
        }

        function onTrackAlbumChanged() {
            root.syncDisplayedPosition();
        }

        function onTrackArtUrlChanged() {
            root.syncDisplayedPosition();
        }

        function onPostTrackChanged() {
            root.syncDisplayedPosition();
        }
    }

    Process {
        id: coverArtDownloader
        property string targetFile: root.artUrl ?? ""
        property string artFilePath: root.artFilePath
        command: ["bash", "-c", `mkdir -p ${root.shellQuote(root.artDownloadLocation)} && { [ -s ${root.shellQuote(artFilePath)} ] || curl -L --fail -sS ${root.shellQuote(targetFile)} -o ${root.shellQuote(artFilePath)}; }`]
        onExited: (exitCode, exitStatus) => {
            root.downloaded = exitCode === 0;
        }
    }

    ColorQuantizer {
        id: colorQuantizer
        source: root.displayedArtFilePath
        depth: 0
        rescaleSize: 1
    }

    Timer {
        running: !root.browserPlayer && root.player?.playbackState === MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: {
            if (root.player)
                root.player.positionChanged();
        }
    }

    Timer {
        running: root.browserPlayer && root.visible && root.playerctlName.length > 0
        interval: 500
        repeat: true
        triggeredOnStart: true
        onTriggered: root.pollBrowserProgress()
    }

    Process {
        id: browserProgressProc
        property string playerName: root.playerctlName
        command: ["bash", "-lc", `playerctl -p ${root.shellQuote(playerName)} status 2>/dev/null; playerctl -p ${root.shellQuote(playerName)} position 2>/dev/null`]

        stdout: StdioCollector {
            onStreamFinished: root.applyPlayerctlSnapshot(text)
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && root.browserPlayer) {
                root.progressAnimating = false;
            }
        }
    }

    component TrackChangeButton: RippleButton {
        implicitWidth: 24
        implicitHeight: 24
        property string iconName
        colBackground: ColorMix.transparentize(root.blendedColors.colSecondaryContainer, 1)
        colBackgroundHover: root.blendedColors.colSecondaryContainerHover
        colRipple: root.blendedColors.colSecondaryContainerActive
        buttonRadius: 999

        contentItem: MaterialIcon {
            text: iconName
            fill: 1
            font.pointSize: 14
            color: root.blendedColors.colOnSecondaryContainer
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
        }
    }

    RectangularShadow {
        anchors.fill: background
        radius: background.radius
        blur: 18
        offset: Qt.vector2d(0, Config.shadowVerticalOffset)
        spread: 1
        color: Colors.windowShadow
        cached: true
    }

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.margins: 4
        color: ColorMix.applyAlpha(root.blendedColors.colLayer0, 1)
        radius: root.radius

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: background.width
                height: background.height
                radius: background.radius
            }
        }

        Image {
            id: blurredArt
            anchors.fill: parent
            source: root.displayedArtFilePath
            sourceSize.width: background.width
            sourceSize.height: background.height
            fillMode: Image.PreserveAspectCrop
            cache: false
            antialiasing: true
            asynchronous: true
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: blurredArt
            saturation: -0.1
            brightness: -0.05
            blurEnabled: true
            blurMax: 64
            blur: 1
            blurMultiplier: 1.4
            opacity: blurredArt.status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic } }
        }

        Rectangle {
            anchors.fill: parent
            color: ColorMix.transparentize(root.blendedColors.colLayer0, 0.3)
            radius: root.radius
        }

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

                Text {
                    id: trackTitle
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    verticalAlignment: Text.AlignTop
                    lineHeightMode: Text.FixedHeight
                    lineHeight: 20
                    font.family: Config.fontFamily
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
                    color: root.blendedColors.colOnLayer0
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    text: (root.player?.trackTitle ?? "") || "Untitled"

                    property real animationDistanceX: 6

                    Behavior on text {
                        SequentialAnimation {
                            alwaysRunToEnd: true
                            ParallelAnimation {
                                NumberAnimation { target: trackTitle; property: "x"; to: -trackTitle.animationDistanceX; duration: 150; easing.type: Easing.InSine }
                                NumberAnimation { target: trackTitle; property: "opacity"; to: 0; duration: 150; easing.type: Easing.InSine }
                            }
                            PropertyAction {}
                            PropertyAction { target: trackTitle; property: "x"; value: trackTitle.animationDistanceX }
                            ParallelAnimation {
                                NumberAnimation { target: trackTitle; property: "x"; to: 0; duration: 150; easing.type: Easing.OutSine }
                                NumberAnimation { target: trackTitle; property: "opacity"; to: 1; duration: 150; easing.type: Easing.OutSine }
                            }
                        }
                    }
                }

                Text {
                    id: trackArtist
                    Layout.fillWidth: true
                    font.family: Config.fontFamily
                    font.pixelSize: 12
                    color: root.blendedColors.colSubtext
                    elide: Text.ElideRight
                    renderType: Text.NativeRendering
                    text: root.player?.trackArtist ?? ""
                }

                Item { Layout.fillHeight: true }

                Item {
                    Layout.fillWidth: true
                    implicitHeight: trackTime.implicitHeight + sliderRow.implicitHeight + 5

                    Text {
                        id: trackTime
                        anchors.bottom: sliderRow.top
                        anchors.bottomMargin: 5
                        anchors.left: parent.left
                        font.family: Config.fontFamily
                        font.pixelSize: 11
                        color: root.blendedColors.colSubtext
                        elide: Text.ElideRight
                        renderType: Text.NativeRendering
                        text: `${formatTime(root.displayedPosition)} / ${formatTime(root.player?.length)}`
                    }

                    RowLayout {
                        id: sliderRow
                        anchors {
                            bottom: parent.bottom
                            left: parent.left
                            right: parent.right
                        }
                        TrackChangeButton {
                            iconName: "skip_previous"
                            downAction: () => root.player?.previous()
                        }
                        Item {
                            id: progressBarContainer
                            Layout.fillWidth: true
                            implicitHeight: Math.max(32, sliderLoader.implicitHeight, progressBarLoader.implicitHeight)
                            clip: false

                            Loader {
                                id: sliderLoader
                                anchors.fill: parent
                                active: root.player?.canSeek ?? false
                                sourceComponent: StyledSlider {
                                    configuration: StyledSlider.Configuration.Wavy
                                    animateWave: root.progressAnimating
                                    highlightColor: root.blendedColors.colPrimary
                                    trackColor: root.blendedColors.colSecondaryContainer
                                    handleColor: root.blendedColors.colPrimary
                                    value: (root.player?.length ?? 0) > 0
                                        ? (root.displayedPosition / root.player.length) : 0
                                    onMoved: {
                                        if (!root.player)
                                            return;
                                        root.player.position = value * root.player.length;
                                        if (root.browserPlayer) {
                                            root.displayedPosition = value * root.player.length;
                                            root.polledPosition = root.displayedPosition;
                                            root.lastPolledPosition = root.displayedPosition;
                                            root.stalledPolls = 0;
                                        }
                                    }
                                }
                            }

                            Loader {
                                id: progressBarLoader
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.left
                                    right: parent.right
                                }
                                active: !(root.player?.canSeek ?? false)
                                sourceComponent: StyledProgressBar {
                                    wavy: root.progressAnimating
                                    animateWave: root.progressAnimating
                                    highlightColor: root.blendedColors.colPrimary
                                    trackColor: root.blendedColors.colSecondaryContainer
                                    value: (root.player?.length ?? 0) > 0
                                        ? (root.displayedPosition / root.player.length) : 0
                                }
                            }
                        }
                        TrackChangeButton {
                            iconName: "skip_next"
                            downAction: () => root.player?.next()
                        }
                    }

                    RippleButton {
                        id: playPauseButton
                        anchors.right: parent.right
                        anchors.bottom: sliderRow.top
                        anchors.bottomMargin: 5
                        property real size: 44
                        implicitWidth: size
                        implicitHeight: size
                        downAction: () => root.player?.togglePlaying()

                        buttonRadius: root.player?.isPlaying ? 12 : size / 2
                        colBackground: root.player?.isPlaying ? root.blendedColors.colPrimary : root.blendedColors.colSecondaryContainer
                        colBackgroundHover: root.player?.isPlaying ? root.blendedColors.colPrimaryHover : root.blendedColors.colSecondaryContainerHover
                        colRipple: root.player?.isPlaying ? root.blendedColors.colPrimaryActive : root.blendedColors.colSecondaryContainerActive

                        contentItem: MaterialIcon {
                            text: root.player?.isPlaying ? "pause" : "play_arrow"
                            fill: 1
                            font.pointSize: 16
                            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
                            color: root.player?.isPlaying ? root.blendedColors.colOnPrimary : root.blendedColors.colOnSecondaryContainer
                            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
                        }
                    }
                }
            }
        }
    }

    function formatTime(sec) {
        const s = Math.max(0, Math.floor(sec ?? 0));
        const m = Math.floor(s / 60);
        const r = s % 60;
        return m + ":" + (r < 10 ? "0" : "") + r;
    }

    function resetProgressState(): void {
        root.polledStatus = "Stopped";
        root.polledPosition = 0;
        root.lastPolledPosition = 0;
        root.hasPollSample = false;
        root.stalledPolls = 0;
        root.progressAnimating = false;
        root.syncDisplayedPosition();
        if (root.browserPlayer)
            root.pollBrowserProgress();
    }

    function syncDisplayedPosition(): void {
        if (root.browserPlayer) {
            root.displayedPosition = root.clampPosition(root.polledPosition);
            return;
        }

        root.displayedPosition = root.clampPosition(root.player?.position ?? 0);
        root.progressAnimating = root.player?.playbackState === MprisPlaybackState.Playing;
    }

    function clampPosition(position: real): real {
        const safePosition = Math.max(0, position ?? 0);
        const length = Math.max(0, root.player?.length ?? 0);
        return length > 0 ? Math.min(safePosition, length) : safePosition;
    }

    function pollBrowserProgress(): void {
        if (!root.browserPlayer || root.playerctlName.length === 0 || browserProgressProc.running)
            return;

        browserProgressProc.playerName = root.playerctlName;
        browserProgressProc.command = ["bash", "-lc", `playerctl -p ${root.shellQuote(browserProgressProc.playerName)} status 2>/dev/null; playerctl -p ${root.shellQuote(browserProgressProc.playerName)} position 2>/dev/null`];
        browserProgressProc.running = true;
    }

    function applyPlayerctlSnapshot(text: string): void {
        const lines = String(text ?? "").trim().split(/\r?\n/).filter(Boolean);
        if (lines.length === 0)
            return;

        const nextStatus = lines[0];
        const nextPosition = lines.length > 1 ? parseFloat(lines[1]) : root.polledPosition;
        const validPosition = Number.isFinite(nextPosition) ? root.clampPosition(nextPosition) : root.polledPosition;
        const moved = !root.hasPollSample || Math.abs(validPosition - root.lastPolledPosition) > 0.05;

        root.polledStatus = nextStatus;
        root.polledPosition = validPosition;
        root.displayedPosition = validPosition;

        if (nextStatus === "Playing") {
            root.stalledPolls = moved ? 0 : root.stalledPolls + 1;
            root.progressAnimating = root.stalledPolls < 2;
        } else {
            root.stalledPolls = 0;
            root.progressAnimating = false;
        }

        root.lastPolledPosition = validPosition;
        root.hasPollSample = true;
    }

    function isBrowserPlayer(name: string): bool {
        return name.startsWith("org.mpris.MediaPlayer2.firefox")
            || name.startsWith("org.mpris.MediaPlayer2.chromium")
            || name.startsWith("org.mpris.MediaPlayer2.chrome")
            || name.startsWith("org.mpris.MediaPlayer2.brave")
            || name.startsWith("org.mpris.MediaPlayer2.zen")
            || name.startsWith("org.mpris.MediaPlayer2.plasma-browser-integration");
    }

    function playerctlNameFromDbus(name: string): string {
        return name.startsWith("org.mpris.MediaPlayer2.")
            ? name.slice("org.mpris.MediaPlayer2.".length)
            : name;
    }

    function isRemoteArt(url: string): bool {
        return url.startsWith("http://") || url.startsWith("https://");
    }

    function resolveArtSource(url: string): string {
        if (root.isRemoteArt(url))
            return url;
        if (url.startsWith("file://"))
            return url;
        if (url.startsWith("/"))
            return Qt.resolvedUrl(url);
        return url;
    }

    function shellQuote(value: string): string {
        return "'" + String(value ?? "").replace(/'/g, "'\"'\"'") + "'";
    }
}
