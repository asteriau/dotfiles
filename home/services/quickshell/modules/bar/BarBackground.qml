import QtQuick
import qs.modules.common

// The horizontal bar's flat background, split out of BarLayoutHorizontal so
// the morph layer can sit BETWEEN this and the widget content (faithful hefty
// layering: the bar content draws ON the morph shape, not under a separate
// panel on top). Pixel-identical to the pre-split bar background.
Rectangle {
    id: root

    color: Appearance.colors.background
    radius: Config.bar.rounding ? Appearance.layout.radiusBar : 0

    Rectangle {
        visible: Config.bar.rounding
        width: root.radius
        height: root.radius
        anchors.top: Config.bar.onEnd ? undefined : parent.top
        anchors.bottom: Config.bar.onEnd ? parent.bottom : undefined
        anchors.left: parent.left
        color: Appearance.colors.background
    }
    Rectangle {
        visible: Config.bar.rounding
        width: root.radius
        height: root.radius
        anchors.top: Config.bar.onEnd ? undefined : parent.top
        anchors.bottom: Config.bar.onEnd ? parent.bottom : undefined
        anchors.right: parent.right
        color: Appearance.colors.background
    }
}
