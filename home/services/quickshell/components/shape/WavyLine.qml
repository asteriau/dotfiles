import QtQuick
import QtQuick.Shapes
import qs.utils

Item {
    id: root

    property real amplitudeMultiplier: 0.5
    property real frequency: 6
    property color color: Colors.colPrimary ?? "#685496"
    property real lineWidth: 4
    property real fullLength: width

    // No-op back-compat with the old Canvas API: StyledSlider calls
    // requestPaint() on value/visibility changes; Shape redraws reactively.
    function requestPaint(): void {}

    // Animated phase. NumberAnimation drives Shape geometry on the render
    // thread instead of the QML JS thread the old Canvas onPaint ran on.
    property real phase: 0
    NumberAnimation on phase {
        from: 0
        to: 2 * Math.PI
        duration: 2500
        loops: Animation.Infinite
        running: root.visible
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathPolyline {
                path: {
                    const w = root.width;
                    const h = root.height;
                    const amp = root.lineWidth * root.amplitudeMultiplier;
                    const cy = h / 2;
                    const len = root.fullLength;
                    const pts = [];
                    const step = 1;
                    const half = root.lineWidth / 2;
                    for (let x = half; x <= w - half; x += step)
                        pts.push(Qt.point(x, cy + amp * Math.sin(root.frequency * 2 * Math.PI * x / len + root.phase)));
                    return pts;
                }
            }
        }
    }
}
