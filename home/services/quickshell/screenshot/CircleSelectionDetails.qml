import QtQuick
import QtQuick.Shapes
import Quickshell
import qs.utils

Item {
    id: root
    required property color color
    required property color overlayColor
    required property list<point> points
    property int strokeWidth: Config.regionCircleStrokeWidth

    Rectangle {
        id: darkenOverlay
        z: 1
        anchors.fill: parent
        color: root.overlayColor
    }

    Shape {
        id: shape
        z: 2
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: shapePath
            strokeWidth: root.strokeWidth
            pathHints: ShapePath.PathLinear
            fillColor: "transparent"
            strokeColor: root.color
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathPolyline {
                path: root.points
            }
        }
    }
}
