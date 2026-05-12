import QtQuick
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property int   implicitSize: 20
    property int   lineWidth: 2
    property real  value: 0
    property color color: Appearance.colors.m3onSecondaryContainer
    property bool  enableAnimation: false
    default property Item textMask: Item {
        width: root.implicitSize
        height: root.implicitSize
    }

    implicitWidth:  implicitSize
    implicitHeight: implicitSize

    property real degree: value * 360
    property real centerX: root.width  / 2
    property real centerY: root.height / 2
    property real arcRadius: root.implicitSize / 2 - root.lineWidth / 2 - 0.5
    property real startAngle: -90

    Behavior on degree {
        enabled: root.enableAnimation
        NumberAnimation { duration: 800; easing.type: Easing.OutCubic }
    }

    Rectangle {
        id: contentItem
        anchors.fill: parent
        radius: implicitSize / 2
        color: Qt.rgba(root.color.r, root.color.g, root.color.b, 0.5)
        visible: false
        layer.enabled: true
        layer.smooth: true

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                id: primaryPath
                pathHints: ShapePath.PathSolid & ShapePath.PathNonIntersecting
                strokeColor: root.color
                strokeWidth: root.lineWidth
                capStyle: ShapePath.RoundCap
                fillColor: root.color

                startX: root.centerX
                startY: root.centerY

                PathAngleArc {
                    moveToStart: false
                    centerX: root.centerX
                    centerY: root.centerY
                    radiusX: root.arcRadius
                    radiusY: root.arcRadius
                    startAngle: root.startAngle
                    sweepAngle: root.degree
                }
                PathLine {
                    x: primaryPath.startX
                    y: primaryPath.startY
                }
            }
        }
    }

    OpacityMask {
        anchors.fill: parent
        source: contentItem
        invert: true
        maskSource: root.textMask
    }
}
