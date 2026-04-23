import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.utils

Rectangle {
    id: root

    readonly property var player: MprisState.player

    readonly property string trackTitle: player?.trackTitle ?? "No media"
    readonly property string trackArtist: player?.trackArtist ?? ""
    readonly property string trackAlbum: player?.trackAlbum ?? ""
    readonly property string identity: player?.identity ?? ""
    readonly property bool isPlaying: player?.isPlaying ?? false
    readonly property real trackLen: Math.max(1, player?.length ?? 0)
    readonly property real trackPos: player?.position ?? 0
    readonly property string artUrl: player?.trackArtUrl ?? ""
    readonly property string cacheDir: StandardPaths.writableLocation(StandardPaths.CacheLocation) + "/quickshell/coverart"
    readonly property string artFile: artUrl.length > 0 ? cacheDir + "/" + Qt.md5(artUrl) : ""
    property bool artDownloaded: false
    readonly property string displayedArt: artDownloaded && artFile.length > 0 ? "file://" + artFile : ""

    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + 32
    radius: 28
    color: Colors.surfaceContainerHigh
    antialiasing: true

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
            radius: 28
            color: "black"
            antialiasing: true
        }
    }

    onArtUrlChanged: {
        artDownloaded = false;
        if (artUrl.length === 0)
            return;
        artDownloader.command = ["bash", "-c", `mkdir -p '${cacheDir}' && { [ -s '${artFile}' ] || curl -4 -sSL '${artUrl}' -o '${artFile}'; }`];
        artDownloader.running = true;
    }

    Process {
        id: artDownloader
        onExited: code => { if (code === 0) root.artDownloaded = true; }
    }

    // Blurred album art background
    Image {
        id: blurredArt
        anchors.fill: parent
        source: root.displayedArt
        fillMode: Image.PreserveAspectCrop
        cache: false
        asynchronous: true
        visible: source.toString().length > 0

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            blurMultiplier: 1.2
        }
    }

    // Tint overlay
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Colors.surfaceContainerHigh.r, Colors.surfaceContainerHigh.g, Colors.surfaceContainerHigh.b, blurredArt.visible ? 0.55 : 0)
    }

    // Fallback gradient when no art
    Rectangle {
        anchors.fill: parent
        visible: !blurredArt.visible
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.35) }
            GradientStop { position: 0.55; color: Qt.rgba(Colors.primaryContainer.r, Colors.primaryContainer.g, Colors.primaryContainer.b, 0.75) }
            GradientStop { position: 1; color: "transparent" }
        }
    }

    Timer {
        interval: 1000
        running: root.visible && root.isPlaying
        repeat: true
        onTriggered: if (root.player) root.player.positionChanged()
    }

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // App row
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Album art thumbnail
            Item {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                visible: blurredArt.visible

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: Colors.surfaceContainerHighest
                    antialiasing: true
                }

                Item {
                    anchors.fill: parent
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: thumbMask
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                    }

                    Image {
                        anchors.fill: parent
                        source: root.displayedArt
                        fillMode: Image.PreserveAspectCrop
                        cache: false
                        asynchronous: true
                    }
                }

                Item {
                    id: thumbMask
                    anchors.fill: parent
                    visible: false
                    layer.enabled: true
                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: "black"
                        antialiasing: true
                    }
                }
            }

            // Host chip (when no art)
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                visible: !blurredArt.visible
                radius: 12
                color: Colors.surfaceContainerHighest
                antialiasing: true

                Text {
                    anchors.centerIn: parent
                    text: "laptop_mac"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 14
                    color: Colors.m3onSurfaceVariant
                    renderType: Text.NativeRendering
                }
            }

            Text {
                Layout.fillWidth: true
                text: (root.identity.length > 0 ? root.identity : "Media") + " · on this host"
                color: Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Rectangle {
                Layout.preferredHeight: 26
                implicitWidth: outputRow.implicitWidth + 24
                radius: 14
                color: Colors.surfaceContainerHighest
                antialiasing: true

                RowLayout {
                    id: outputRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "speaker"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 14
                        color: Colors.m3onSurfaceVariant
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: "Output"
                        color: Colors.foreground
                        font.family: Config.fontFamily
                        font.pixelSize: 11
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
        }

        // Title / subtitle
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.trackTitle
                color: Colors.foreground
                font.family: Config.fontFamily
                font.pixelSize: 18
                font.weight: Font.DemiBold
                font.letterSpacing: -0.18
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: [root.trackArtist, root.trackAlbum].filter(s => s.length > 0).join(" · ")
                visible: text.length > 0
                color: Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 13
                elide: Text.ElideRight
            }
        }

        // Progress
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 4
            spacing: 10

            Text {
                text: formatTime(root.trackPos)
                color: Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 11
                Layout.minimumWidth: 32
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 12

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 4
                    radius: 2
                    color: Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.2)
                    antialiasing: true

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * Math.max(0, Math.min(1, root.trackPos / root.trackLen))
                        radius: 2
                        color: Colors.foreground
                        antialiasing: true
                    }

                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: Colors.foreground
                        antialiasing: true
                        x: Math.max(0, Math.min(parent.width - 12, parent.width * Math.max(0, Math.min(1, root.trackPos / root.trackLen)) - 6))
                        y: -4
                        border.color: Colors.surfaceContainerHigh
                        border.width: 3
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: root.player?.canSeek ?? false
                    onClicked: ev => {
                        if (!root.player)
                            return;
                        const f = Math.max(0, Math.min(1, ev.x / width));
                        root.player.position = f * root.trackLen;
                    }
                }
            }

            Text {
                text: formatTime(root.trackLen)
                color: Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 11
                Layout.minimumWidth: 32
                horizontalAlignment: Text.AlignRight
            }
        }

        // Transport
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            TxButton {
                icon: "favorite"
                iconColor: Colors.mpris
                iconFilled: true
            }

            Item { Layout.fillWidth: true }

            TxButton {
                icon: "skip_previous"
                iconSize: 22
                iconFilled: true
                btnEnabled: root.player?.canGoPrevious ?? false
                onClicked: root.player?.previous()
            }

            Rectangle {
                Layout.preferredWidth: 52
                Layout.preferredHeight: 52
                Layout.leftMargin: 6
                Layout.rightMargin: 6
                radius: 26
                color: Colors.foreground
                antialiasing: true

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "pause" : "play_arrow"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 26
                    font.variableAxes: ({ FILL: 1, wght: 400, opsz: 24, GRAD: 0 })
                    color: Colors.background
                    renderType: Text.NativeRendering
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: root.player?.canTogglePlaying ?? false
                    onClicked: root.player?.togglePlaying()
                }
            }

            TxButton {
                icon: "skip_next"
                iconSize: 22
                iconFilled: true
                btnEnabled: root.player?.canGoNext ?? false
                onClicked: root.player?.next()
            }

            Item { Layout.fillWidth: true }

            TxButton {
                icon: "playlist_add"
                iconSize: 18
                iconColor: Colors.m3onSurfaceVariant
            }
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
        property string icon
        property int iconSize: 18
        property color iconColor: Colors.foreground
        property bool iconFilled: false
        property bool btnEnabled: true
        signal clicked

        Layout.preferredWidth: 44
        Layout.preferredHeight: 44

        Text {
            anchors.centerIn: parent
            text: btn.icon
            font.family: "Material Symbols Rounded"
            font.pixelSize: btn.iconSize
            font.variableAxes: ({
                    FILL: btn.iconFilled ? 1 : 0,
                    wght: 400,
                    opsz: 24,
                    GRAD: 0
                })
            color: btn.iconColor
            opacity: btn.btnEnabled ? 1 : 0.35
            renderType: Text.NativeRendering
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            enabled: btn.btnEnabled
            onClicked: btn.clicked()
        }
    }
}
