pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes

// Vertical bar background shape. Mirrors NotchShape's geometry rotated 90°:
// concave fillets at the screen-edge corners, convex rounding on the free side.
Item {
    id: root

    property real bodyWidth:    46
    property real bodyHeight:   800
    property real screenRadius: 6     // concave depth at screen-edge corners
    property real freeRadius:   18    // convex radius on the free-side corners
    property bool onEnd:        false // true = right bar (mirrors horizontally)
    property color fillColor:   "black"

    implicitWidth:  bodyWidth
    implicitHeight: bodyHeight

    // Clamp so path stays geometrically valid regardless of bar width.
    readonly property real sr: Math.min(screenRadius, bodyWidth / 3)
    readonly property real fr: Math.min(freeRadius,   bodyWidth - sr - 1)

    // Left bar (screen edge = left).
    Shape {
        anchors.fill: parent
        visible: !root.onEnd
        antialiasing: true
        layer.enabled: true
        layer.samples: 4
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: leftPath
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: root.fillColor

            readonly property real w:  root.bodyWidth
            readonly property real h:  root.bodyHeight
            readonly property real sr: root.sr
            readonly property real fr: root.fr

            startX: 0; startY: 0

            PathQuad { x: leftPath.sr; y: leftPath.sr; controlX: leftPath.sr; controlY: 0 }
            PathLine { x: leftPath.w - leftPath.fr; y: leftPath.sr }
            PathQuad { x: leftPath.w; y: leftPath.sr + leftPath.fr; controlX: leftPath.w; controlY: leftPath.sr }
            PathLine { x: leftPath.w; y: leftPath.h - leftPath.sr - leftPath.fr }
            PathQuad { x: leftPath.w - leftPath.fr; y: leftPath.h - leftPath.sr; controlX: leftPath.w; controlY: leftPath.h - leftPath.sr }
            PathLine { x: leftPath.sr; y: leftPath.h - leftPath.sr }
            PathQuad { x: 0; y: leftPath.h; controlX: leftPath.sr; controlY: leftPath.h }
            PathLine { x: 0; y: 0 }
        }
    }

    // Right bar (screen edge = right, mirrored).
    Shape {
        anchors.fill: parent
        visible: root.onEnd
        antialiasing: true
        layer.enabled: true
        layer.samples: 4
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: rightPath
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: root.fillColor

            readonly property real w:  root.bodyWidth
            readonly property real h:  root.bodyHeight
            readonly property real sr: root.sr
            readonly property real fr: root.fr

            startX: rightPath.w; startY: 0

            PathQuad { x: rightPath.w - rightPath.sr; y: rightPath.sr; controlX: rightPath.w - rightPath.sr; controlY: 0 }
            PathLine { x: rightPath.fr; y: rightPath.sr }
            PathQuad { x: 0; y: rightPath.sr + rightPath.fr; controlX: 0; controlY: rightPath.sr }
            PathLine { x: 0; y: rightPath.h - rightPath.sr - rightPath.fr }
            PathQuad { x: rightPath.fr; y: rightPath.h - rightPath.sr; controlX: 0; controlY: rightPath.h - rightPath.sr }
            PathLine { x: rightPath.w - rightPath.sr; y: rightPath.h - rightPath.sr }
            PathQuad { x: rightPath.w; y: rightPath.h; controlX: rightPath.w - rightPath.sr; controlY: rightPath.h }
            PathLine { x: rightPath.w; y: 0 }
        }
    }

    Behavior on fillColor { ColorAnimation { duration: 320; easing.type: Easing.OutCubic } }
}
