import QtQuick
import qs.components.effects
import qs.components.shape
import qs.utils

// z:3 active-workspace indicator. Uses AnimatedTabPair to smoothly slide
// between workspaces and morphs the silhouette based on the current id so
// each workspace has a distinct personality.
Item {
    id: root

    property int  indexInGroup: 0
    property int  activeWorkspaceId: 1
    property real buttonWidth: 26
    property real activeMargin: 2
    property bool vertical: false
    property real verticalPadding: 4

    AnimatedTabPair {
        id: tabPair
        index: root.indexInGroup
    }

    readonly property real indicatorPos:
        Math.min(tabPair.idx1, tabPair.idx2) * buttonWidth + activeMargin +
        (vertical ? verticalPadding : 0)
    readonly property real indicatorLen:
        Math.abs(tabPair.idx1 - tabPair.idx2) * buttonWidth +
        buttonWidth - activeMargin * 2
    readonly property real indicatorThick:
        buttonWidth - activeMargin * 2

    x:             vertical ? (parent.width - indicatorThick) / 2 : indicatorPos
    y:             vertical ? indicatorPos : (parent.height - indicatorThick) / 2
    implicitWidth:  vertical ? indicatorThick : indicatorLen
    implicitHeight: vertical ? indicatorLen  : indicatorThick

    MaterialShape {
        anchors.fill: parent
        color: Colors.accent

        // Stretchy aspect-ratio morphing helps the shape transition nicely
        // across workspaces as bounding width/height expands dynamically.
        implicitSize: Math.max(parent.width, parent.height)

        readonly property list<var> morphShapes: [
            MaterialShape.Shape.Circle,
            MaterialShape.Shape.Cookie12Sided,
            MaterialShape.Shape.Sunny,
            MaterialShape.Shape.Cookie9Sided,
            MaterialShape.Shape.Clover4Leaf,
            MaterialShape.Shape.Cookie6Sided,
            MaterialShape.Shape.Flower,
            MaterialShape.Shape.Cookie4Sided,
            MaterialShape.Shape.SoftBoom,
            MaterialShape.Shape.Clover8Leaf
        ]

        shape: morphShapes[((root.activeWorkspaceId ?? 1) - 1) % morphShapes.length]
    }
}
