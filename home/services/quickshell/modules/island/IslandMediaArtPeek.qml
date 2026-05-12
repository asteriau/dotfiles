pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

ClippingRectangle {
    id: root

    property MprisPlayer player: MprisState.player
    readonly property string artUrl: (player?.trackArtUrl ?? "").toString()
    readonly property string resolvedArt: artUrl ? MprisState.resolveArtSource(artUrl) : ""

    radius: width / 2
    color: Appearance.colors.surfaceContainerHighest
    antialiasing: true

    property string _aSrc: ""
    property string _bSrc: ""
    property bool _useA: false

    Connections {
        target: root
        function onResolvedArtChanged() {
            if (root._useA) { root._bSrc = root.resolvedArt; root._useA = false; }
            else            { root._aSrc = root.resolvedArt; root._useA = true; }
        }
    }

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true; mipmap: true; asynchronous: true; cache: true
        sourceSize.width: 64; sourceSize.height: 64
        source: root._aSrc
        opacity: root._useA && status === Image.Ready ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.medium2; easing.type: Easing.OutCubic } }
    }
    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true; mipmap: true; asynchronous: true; cache: true
        sourceSize.width: 64; sourceSize.height: 64
        source: root._bSrc
        opacity: !root._useA && status === Image.Ready ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.medium2; easing.type: Easing.OutCubic } }
    }

    MaterialIcon {
        anchors.centerIn: parent
        visible: !root.resolvedArt
        text: "music_note"
        fill: 1
        pixelSize: Math.max(10, root.width * 0.55)
        color: Appearance.colors.foreground
    }
}
