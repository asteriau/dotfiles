pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.components.text
import qs.utils
import qs.utils.state

// Compact media row: circular cover art + 4-bar EQ. Cover crossfades on track
// change; EQ accent color transitions smoothly.
Item {
    id: root

    property MprisPlayer player: MprisState.player
    property color accentColor: Colors.accent

    readonly property string artUrl: (player?.trackArtUrl ?? "").toString()
    readonly property string resolvedArt: artUrl ? MprisState.resolveArtSource(artUrl) : ""
    readonly property bool playing: player?.isPlaying ?? false

    ClippingRectangle {
        id: artClip
        width: 28
        height: 28
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        radius: width / 2
        color: Colors.surfaceContainerHighest
        antialiasing: true

        // Two-layer crossfade. Latch each layer's source so the outgoing layer
        // keeps drawing the previous art while the incoming layer fades in.
        property string _aSrc: ""
        property string _bSrc: ""
        property bool _useA: false

        Connections {
            target: root
            function onResolvedArtChanged() {
                if (artClip._useA) {
                    artClip._bSrc = root.resolvedArt;
                    artClip._useA = false;
                } else {
                    artClip._aSrc = root.resolvedArt;
                    artClip._useA = true;
                }
            }
        }

        Image {
            id: imgA
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
            asynchronous: true
            cache: true
            sourceSize.width: 64
            sourceSize.height: 64
            source: artClip._aSrc
            opacity: artClip._useA && status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutCubic } }
        }
        Image {
            id: imgB
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            smooth: true
            mipmap: true
            asynchronous: true
            cache: true
            sourceSize.width: 64
            sourceSize.height: 64
            source: artClip._bSrc
            opacity: !artClip._useA && status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium2; easing.type: Easing.OutCubic } }
        }

        MaterialIcon {
            anchors.centerIn: parent
            visible: !root.resolvedArt
            text: "music_note"
            fill: 1
            pixelSize: 14
            color: Colors.foreground
        }
    }

    Row {
        id: bars
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 3

        Repeater {
            model: 4
            Rectangle {
                required property int index
                width: 3
                height: 16
                radius: 1.5
                color: root.accentColor
                transformOrigin: Item.Center

                Behavior on color {
                    ColorAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic }
                }

                SequentialAnimation on scale {
                    running: root.playing
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.30; to: 1.00; duration: 360 + index * 90; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.00; to: 0.30; duration: 320 + index * 70; easing.type: Easing.InOutSine }
                }

                scale: root.playing ? scale : 0.32
                opacity: root.playing ? 1 : 0.55
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration } }
            }
        }
    }
}
