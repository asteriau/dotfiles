pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import qs.utils

Item {
    id: root

    property real bodyWidth: 200
    property real bodyHeight: 32
    property real topRadius: 6
    property real bottomRadius: 14
    property color fillColor: "black"

    implicitWidth: bodyWidth
    implicitHeight: bodyHeight

    Shape {
        anchors.fill: parent
        antialiasing: true
        layer.enabled: true
        layer.samples: 4
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: path
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: root.fillColor
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.FlatCap

            readonly property real w:  root.bodyWidth
            readonly property real h:  root.bodyHeight
            readonly property real tr: root.topRadius
            readonly property real br: root.bottomRadius

            startX: 0; startY: 0

            // Top-left concave fillet: quad from (0,0) curving down to (tr, tr).
            // Control point at (tr, 0) pulls curve along top edge outward.
            PathQuad {
                x: path.tr; y: path.tr
                controlX: path.tr; controlY: 0
            }
            // Inner left edge.
            PathLine { x: path.tr; y: path.h - path.br }
            // Bottom-left convex corner.
            PathQuad {
                x: path.tr + path.br; y: path.h
                controlX: path.tr;    controlY: path.h
            }
            // Bottom edge.
            PathLine { x: path.w - path.tr - path.br; y: path.h }
            // Bottom-right convex corner.
            PathQuad {
                x: path.w - path.tr;     y: path.h - path.br
                controlX: path.w - path.tr; controlY: path.h
            }
            // Inner right edge.
            PathLine { x: path.w - path.tr; y: path.tr }
            // Top-right concave fillet.
            PathQuad {
                x: path.w; y: 0
                controlX: path.w - path.tr; controlY: 0
            }
            // Top edge back to origin.
            PathLine { x: 0; y: 0 }
        }
    }

    Behavior on bodyWidth     { NumberAnimation { duration: Appearance.motion.duration.long1; easing.bezierCurve: Appearance.motion.easing.emphasized } }
    Behavior on bodyHeight    { NumberAnimation { duration: Appearance.motion.duration.long1; easing.bezierCurve: Appearance.motion.easing.emphasized } }
    Behavior on topRadius     { NumberAnimation { duration: Appearance.motion.duration.long1; easing.bezierCurve: Appearance.motion.easing.emphasized } }
    Behavior on bottomRadius  { NumberAnimation { duration: Appearance.motion.duration.long1; easing.bezierCurve: Appearance.motion.easing.emphasized } }
    Behavior on fillColor     { ColorAnimation   { duration: Appearance.motion.duration.long1; easing.bezierCurve: Appearance.motion.easing.emphasized } }
}
