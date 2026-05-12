pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Mpris
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property MprisPlayer player: null
    property real position: 0
    property real length: 0
    property bool animating: false
    property bool browserPlayer: false
    property var colors: null

    signal seekRequested(real positionSec)

    implicitHeight: Math.max(32, sliderLoader.implicitHeight, progressBarLoader.implicitHeight)
    clip: false

    Loader {
        id: sliderLoader
        anchors.fill: parent
        active: root.player?.canSeek ?? false
        sourceComponent: StyledSlider {
            configuration: StyledSlider.Configuration.Wavy
            stopIndicatorValues: []
            highlightColor: root.colors?.colPrimary ?? Appearance.colors.accent
            trackColor: root.colors?.colSecondaryContainer ?? Appearance.colors.secondaryContainer
            handleColor: root.colors?.colPrimary ?? Appearance.colors.accent
            value: root.length > 0 ? (root.position / root.length) : 0
            onMoved: root.seekRequested(value * root.length)
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
            wavy: root.animating
            highlightColor: root.colors?.colPrimary ?? Appearance.colors.accent
            trackColor: root.colors?.colSecondaryContainer ?? Appearance.colors.secondaryContainer
            value: root.length > 0 ? (root.position / root.length) : 0
        }
    }
}
