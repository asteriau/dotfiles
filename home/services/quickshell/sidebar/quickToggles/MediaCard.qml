import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.components
import qs.utils

Rectangle {
    id: root

    readonly property var player: MprisState.player ?? MprisState.lastPlayer

    readonly property bool hasPlayer: player !== null && player !== undefined
    readonly property string trackTitle: player?.trackTitle ?? ""
    readonly property string trackArtistRaw: player?.trackArtist ?? ""
    property string trackArtist: ""
    onTrackArtistRawChanged: if (trackArtistRaw.length > 0) trackArtist = trackArtistRaw
    readonly property string trackAlbum: player?.trackAlbum ?? ""
    readonly property string identity: player?.identity ?? ""
    readonly property bool isPlaying: player?.isPlaying ?? false
    readonly property real trackLen: Math.max(1, player?.length ?? 0)
    readonly property real trackPos: player?.position ?? 0
    readonly property string artUrl: player?.trackArtUrl ?? ""

    readonly property string cacheDir: StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/quickshell/coverart"
    readonly property bool artIsLocal: artUrl.startsWith("file://") || artUrl.startsWith("/")
    readonly property bool artIsRemote: artUrl.startsWith("http://") || artUrl.startsWith("https://")
    readonly property string artFile: artIsRemote ? cacheDir + "/" + Qt.md5(artUrl) : ""
    property bool artDownloaded: false
    readonly property string displayedArt: {
        if (artUrl.length === 0) return "";
        if (artIsLocal) return artUrl.startsWith("/") ? "file://" + artUrl : artUrl;
        if (artIsRemote && artDownloaded) return "file://" + artFile;
        return "";
    }
    property string stableArt: ""
    onDisplayedArtChanged: if (displayedArt.length > 0) stableArt = displayedArt
    readonly property bool hasArt: stableArt.length > 0

    readonly property string sourceIcon: {
        const id = identity.toLowerCase();
        if (id.includes("spotify")) return "graphic_eq";
        if (id.includes("firefox") || id.includes("chrom") || id.includes("brave") || id.includes("zen") || id.includes("browser") || id.includes("plasma")) return "public";
        if (id.includes("mpv") || id.includes("vlc") || id.includes("mpd")) return "smart_display";
        if (id.includes("youtube")) return "smart_display";
        return "music_note";
    }

    property int trackVersion: 0
    readonly property string artSource: stableArt.length > 0 ? stableArt + "#v=" + trackVersion : ""

    // Debounce track-change bumps — plasma-browser fires many metadata updates per load
    Timer {
        id: bumpTimer
        interval: 350
        repeat: false
        onTriggered: {
            root.trackVersion++;
            progress.lastGoodFraction = 0;
            progress.holdFraction = -1;
        }
    }
    property string lastArtUrl: ""
    property string lastTitle: ""
    Connections {
        target: root.player
        ignoreUnknownSignals: true
        function onTrackTitleChanged() {
            if (root.player?.trackTitle === root.lastTitle) return;
            root.lastTitle = root.player?.trackTitle ?? "";
            bumpTimer.restart();
        }
        function onTrackArtUrlChanged() {
            if (root.player?.trackArtUrl === root.lastArtUrl) return;
            root.lastArtUrl = root.player?.trackArtUrl ?? "";
            bumpTimer.restart();
        }
    }

    // Dual-slot crossfade state
    property int bgSlot: 0
    property int thumbSlot: 0
    onArtSourceChanged: {
        if (artSource.length === 0) return;
        if (bgSlot === 0) bgB.source = artSource; else bgA.source = artSource;
        if (thumbSlot === 0) thumbB.source = artSource; else thumbA.source = artSource;
    }

    property color accentColor: Colors.mpris
    Behavior on accentColor {
        ColorAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.OutCubic }
    }

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: 260

    radius: 22
    color: root.hasPlayer ? Colors.surfaceContainerLow : Colors.elevated
    Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
    antialiasing: true
    clip: true

    layer.enabled: true
    layer.effect: MultiEffect {
        maskEnabled: true
        maskSource: cardMask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
    }

    Item {
        id: cardMask
        anchors.fill: parent
        visible: false
        layer.enabled: true
        Rectangle {
            anchors.fill: parent
            radius: 22
            color: "black"
            antialiasing: true
        }
    }

    onArtUrlChanged: {
        artDownloaded = false;
        if (!artIsRemote)
            return;
        artDownloader.command = ["bash", "-c", `mkdir -p '${cacheDir}' && { [ -s '${artFile}' ] || curl -4 -sSL '${artUrl}' -o '${artFile}'; }`];
        artDownloader.running = true;
    }

    Process {
        id: artDownloader
        onExited: code => { if (code === 0) root.artDownloaded = true; }
    }

    ColorQuantizer {
        id: quantizer
        source: root.artSource
        depth: 2
        rescaleSize: 1
        onColorsChanged: {
            if (colors.length === 0) {
                root.accentColor = Colors.mpris;
                return;
            }
            // pick most saturated-ish color
            let best = colors[0];
            let bestScore = -1;
            for (const c of colors) {
                const max = Math.max(c.r, c.g, c.b);
                const min = Math.min(c.r, c.g, c.b);
                const sat = max > 0 ? (max - min) / max : 0;
                const lum = 0.5 + 0.5 * (max - 0.5) * 2;
                const score = sat * 1.2 + Math.min(max, 0.85);
                if (score > bestScore) {
                    bestScore = score;
                    best = c;
                }
            }
            // ensure enough brightness for dark UI
            const max = Math.max(best.r, best.g, best.b);
            if (max < 0.5) {
                const k = 0.6 / Math.max(max, 0.01);
                best = Qt.rgba(Math.min(1, best.r * k), Math.min(1, best.g * k), Math.min(1, best.b * k), 1);
            }
            root.accentColor = best;
        }
    }

    // Blurred art background — dual slot crossfade
    Item {
        id: bgLayer
        anchors.fill: parent
        visible: root.hasArt

        Image {
            id: bgA
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: false
            asynchronous: true
            visible: false
            onStatusChanged: if (status === Image.Ready && source.toString() === root.artSource && root.bgSlot !== 0) root.bgSlot = 0
        }
        Image {
            id: bgB
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            cache: false
            asynchronous: true
            visible: false
            onStatusChanged: if (status === Image.Ready && source.toString() === root.artSource && root.bgSlot !== 1) root.bgSlot = 1
        }

        MultiEffect {
            anchors.fill: parent
            source: bgA
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            blurMultiplier: 1.4
            saturation: -0.2
            brightness: -0.05
            opacity: root.bgSlot === 0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic } }
        }
        MultiEffect {
            anchors.fill: parent
            source: bgB
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            blurMultiplier: 1.4
            saturation: -0.2
            brightness: -0.05
            opacity: root.bgSlot === 1 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic } }
        }
    }

    // Dark scrim
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, root.hasArt ? 0.42 : 0)
        Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
    }

    // Accent glow when art present but still loading
    Rectangle {
        anchors.fill: parent
        visible: root.hasPlayer && !root.hasArt
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0; color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.18) }
            GradientStop { position: 1; color: "transparent" }
        }
    }

    // Bottom legibility gradient
    Rectangle {
        anchors.fill: parent
        visible: root.hasArt
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.15) }
            GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.55) }
        }
    }

    // Position ticker
    Timer {
        interval: 1000
        running: root.visible && root.isPlaying
        repeat: true
        onTriggered: if (root.player) root.player.positionChanged()
    }

    // ── Empty state ──────────────────────────────────────────────
    ColumnLayout {
        anchors.centerIn: parent
        visible: !root.hasPlayer
        spacing: 14

        // Accent disk with icon
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 72
            Layout.preferredHeight: 72

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.12)
                border.color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.25)
                border.width: 1
                antialiasing: true
            }

            MaterialIcon {
                anchors.centerIn: parent
                text: "music_off"
                fill: 1
                font.pointSize: 30
                color: Colors.accent
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "No media playing"
                color: Colors.foreground
                font.family: Config.fontFamily
                font.pixelSize: 15
                font.weight: Font.DemiBold
                font.letterSpacing: -0.2
                renderType: Text.NativeRendering
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Start something to see it here"
                color: Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 12
                renderType: Text.NativeRendering
            }
        }
    }

    // ── Bottom-centered source (icon + program name) ─────────────
    RowLayout {
        id: sourceRow
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 12
        visible: root.hasPlayer && root.identity.length > 0
        spacing: 5

        MaterialIcon {
            text: root.sourceIcon
            fill: 1
            font.pointSize: 13
            color: Colors.m3onSurfaceVariant
        }

        Text {
            text: root.identity
            color: Colors.m3onSurfaceVariant
            font.family: Config.fontFamily
            font.pixelSize: 12
            font.weight: Font.Medium
            font.letterSpacing: -0.1
            renderType: Text.NativeRendering
        }
    }

    // ── Content ──────────────────────────────────────────────────
    ColumnLayout {
        id: col
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: transport.top
        anchors.topMargin: 18
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.bottomMargin: 16
        spacing: 12
        visible: root.hasPlayer

        // Hero row: thumb + title/artist + identity chip
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            // Album thumb (circle)
            Item {
                id: thumb
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64

                Rectangle {
                    id: thumbBg
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.35)
                    antialiasing: true

                    MaterialIcon {
                        anchors.centerIn: parent
                        visible: !root.hasArt
                        text: "music_note"
                        fill: 1
                        font.pointSize: 28
                        color: Colors.foreground
                        opacity: 0.85
                    }
                }

                Image {
                    id: thumbA
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    visible: root.hasArt
                    opacity: root.thumbSlot === 0 ? 1 : 0
                    layer.enabled: visible
                    layer.smooth: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: thumbMask
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                    }
                    Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic } }
                    onStatusChanged: if (status === Image.Ready && source.toString() === root.artSource && root.thumbSlot !== 0) root.thumbSlot = 0
                }
                Image {
                    id: thumbB
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    cache: false
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    visible: root.hasArt
                    opacity: root.thumbSlot === 1 ? 1 : 0
                    layer.enabled: visible
                    layer.smooth: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: thumbMask
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                    }
                    Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic } }
                    onStatusChanged: if (status === Image.Ready && source.toString() === root.artSource && root.thumbSlot !== 1) root.thumbSlot = 1
                }

                Item {
                    id: thumbMask
                    anchors.fill: parent
                    visible: false
                    layer.enabled: true
                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "black"
                        antialiasing: true
                    }
                }
            }

            // Title + artist
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                ShadowText {
                    Layout.fillWidth: true
                    text: root.trackTitle
                    color: Colors.foreground
                    font.family: Config.fontFamily
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
                    font.letterSpacing: -0.2
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    implicitHeight: 22
                }

                ShadowText {
                    Layout.fillWidth: true
                    visible: root.trackArtist.length > 0
                    text: root.trackArtist
                    color: Colors.m3onSurfaceVariant
                    font.family: Config.fontFamily
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    implicitHeight: 18
                }
            }

        }

        Item { Layout.fillWidth: true; Layout.fillHeight: true }

        // ── Wavy progress ─────────────────────────────────────────
        Item {
            id: progress
            Layout.fillWidth: true
            Layout.preferredHeight: 28

            readonly property real rawLen: root.player?.length ?? 0
            readonly property real rawPos: root.player?.position ?? 0
            property real lastGoodFraction: 0
            property real fraction: {
                if (rawLen > 1 && rawPos >= 0 && rawPos <= rawLen * 1.05) {
                    const f = Math.max(0, Math.min(1, rawPos / rawLen));
                    lastGoodFraction = f;
                    return f;
                }
                return lastGoodFraction;
            }
            property real dragFraction: -1
            property real holdFraction: -1
            Timer {
                id: seekHoldTimer
                interval: 700
                onTriggered: progress.holdFraction = -1
            }
            readonly property real displayFraction:
                dragFraction >= 0 ? dragFraction :
                holdFraction >= 0 ? holdFraction : fraction

            readonly property int playheadSize: 10
            readonly property int gap: 6
            readonly property real playheadX: Math.max(0, Math.min(width, width * displayFraction))
            readonly property real leftEnd: Math.max(0, playheadX - gap - playheadSize / 2)
            readonly property real rightStart: Math.min(width, playheadX + gap + playheadSize / 2)

            // Elapsed wavy
            WavyLine {
                id: wave
                anchors.verticalCenter: parent.verticalCenter
                x: 0
                width: progress.leftEnd
                height: 16
                color: root.accentColor
                lineWidth: 3
                amplitudeMultiplier: 1.2
                frequency: Math.max(3, width / 26)
                fullLength: width
                phaseSpeed: root.isPlaying ? 1.0 : 0.0
                visible: width > 4
            }

            // Remaining flat
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x: progress.rightStart
                width: Math.max(0, parent.width - progress.rightStart)
                height: 3
                radius: 1.5
                color: Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.32)
                antialiasing: true
                visible: width > 1
            }

            // Playhead
            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: progress.playheadSize
                height: progress.playheadSize
                radius: progress.playheadSize / 2
                x: progress.playheadX - progress.playheadSize / 2
                color: root.accentColor
                antialiasing: true
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                enabled: root.player?.canSeek ?? false

                function frac(mx) {
                    return Math.max(0, Math.min(1, mx / progress.width));
                }
                onPressed: ev => { progress.dragFraction = frac(ev.x + anchors.margins); }
                onPositionChanged: ev => {
                    if (pressed) progress.dragFraction = frac(ev.x + anchors.margins);
                }
                onReleased: ev => {
                    if (!root.player) { progress.dragFraction = -1; return; }
                    const f = frac(ev.x + anchors.margins);
                    root.player.position = f * root.trackLen;
                    progress.holdFraction = f;
                    progress.lastGoodFraction = f;
                    seekHoldTimer.restart();
                    progress.dragFraction = -1;
                }
                onCanceled: progress.dragFraction = -1
            }
        }

        // Time labels
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            ShadowText {
                text: formatTime(root.trackPos)
                color: Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 11
                opacity: 0.85
            }
            Item { Layout.fillWidth: true }
            ShadowText {
                text: formatTime(root.trackLen)
                color: Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 11
                opacity: 0.85
            }
        }

    }

    // ── Transport (anchored above source) ────────────────────────
    Row {
        id: transport
        visible: root.hasPlayer
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: sourceRow.top
        anchors.bottomMargin: 20
        spacing: 16

        TxButton {
            iconName: "skip_previous"
            iconPx: 26
            enabled: root.player?.canGoPrevious ?? false
            onTapped: root.player?.previous()
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            id: playBtn
            width: 56
            height: 56
            radius: height / 2
            color: root.accentColor
            antialiasing: true
            anchors.verticalCenter: parent.verticalCenter
            scale: playArea.pressed ? 0.94 : (playArea.containsMouse ? 1.05 : 1.0)

            Behavior on scale { NumberAnimation { duration: M3Easing.durationShort3; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }

            MaterialIcon {
                anchors.centerIn: parent
                text: root.isPlaying ? "pause" : "play_arrow"
                fill: 1
                font.pointSize: 26
                color: {
                    const c = root.accentColor;
                    const lum = 0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b;
                    return lum > 0.55 ? Colors.background : Colors.foreground;
                }
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
            }

            MouseArea {
                id: playArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                enabled: root.player?.canTogglePlaying ?? false
                onClicked: root.player?.togglePlaying()
            }
        }

        TxButton {
            iconName: "skip_next"
            iconPx: 26
            enabled: root.player?.canGoNext ?? false
            onTapped: root.player?.next()
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    function formatTime(sec) {
        const s = Math.max(0, Math.floor(sec));
        const m = Math.floor(s / 60);
        const r = s % 60;
        return m + ":" + (r < 10 ? "0" : "") + r;
    }

    component TxButton: Item {
        id: btn
        property string iconName
        property int iconPx: 22
        property bool enabled: true
        signal tapped

        implicitWidth: 44
        implicitHeight: 44
        width: 44
        height: 44

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: area.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: btn.iconName
            fill: 1
            font.pointSize: btn.iconPx
            color: Colors.foreground
            opacity: btn.enabled ? 0.95 : 0.35
            scale: area.pressed ? 0.9 : (area.containsMouse ? 1.08 : 1.0)
            Behavior on scale { NumberAnimation { duration: M3Easing.durationShort3; easing.type: Easing.OutCubic } }
        }

        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: btn.enabled
            onClicked: btn.tapped()
        }
    }
}
