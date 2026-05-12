pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property MprisPlayer player: null
    property var colors: null
    property real playPauseSize: 44
    property real position: 0
    property real length: 0

    default property alias content: slot.data

    implicitHeight: trackTime.implicitHeight + sliderRow.implicitHeight + 5

    function formatTime(sec) {
        const s = Math.max(0, Math.floor(sec ?? 0));
        const m = Math.floor(s / 60);
        const r = s % 60;
        return m + ":" + (r < 10 ? "0" : "") + r;
    }

    component TrackChangeButton: RippleButton {
        implicitWidth: 24
        implicitHeight: 24
        property string iconName
        colBackground: ColorUtils.transparentize(root.colors?.colSecondaryContainer ?? Appearance.colors.secondaryContainer, 1)
        colBackgroundHover: root.colors?.colSecondaryContainerHover ?? Appearance.colors.secondaryContainer
        colRipple: root.colors?.colSecondaryContainerActive ?? Appearance.colors.accent
        buttonRadius: 999

        contentItem: MaterialIcon {
            text: iconName
            fill: 1
            font.pointSize: 14
            color: root.colors?.colOnSecondaryContainer ?? Appearance.colors.foreground
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
        }
    }

    StyledText {
        id: trackTime
        anchors.bottom: sliderRow.top
        anchors.bottomMargin: 5
        anchors.left: parent.left
        font.pixelSize: 11
        color: root.colors?.colSubtext ?? Appearance.colors.m3onSurfaceVariant
        elide: Text.ElideRight
        text: `${root.formatTime(root.position)} / ${root.formatTime(root.length)}`
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
            id: slot
            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitHeight: 32
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
        implicitWidth: root.playPauseSize
        implicitHeight: root.playPauseSize
        downAction: () => root.player?.togglePlaying()

        buttonRadius: root.player?.isPlaying ? 12 : root.playPauseSize / 2
        colBackground: root.player?.isPlaying
            ? (root.colors?.colPrimary ?? Appearance.colors.accent)
            : (root.colors?.colSecondaryContainer ?? Appearance.colors.secondaryContainer)
        colBackgroundHover: root.player?.isPlaying
            ? (root.colors?.colPrimaryHover ?? Appearance.colors.accent)
            : (root.colors?.colSecondaryContainerHover ?? Appearance.colors.secondaryContainer)
        colRipple: root.player?.isPlaying
            ? (root.colors?.colPrimaryActive ?? Appearance.colors.accent)
            : (root.colors?.colSecondaryContainerActive ?? Appearance.colors.accent)

        contentItem: MaterialIcon {
            text: root.player?.isPlaying ? "pause" : "play_arrow"
            fill: 1
            font.pointSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.player?.isPlaying
                ? (root.colors?.colOnPrimary ?? Appearance.colors.foreground)
                : (root.colors?.colOnSecondaryContainer ?? Appearance.colors.foreground)
            Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
        }
    }
}
