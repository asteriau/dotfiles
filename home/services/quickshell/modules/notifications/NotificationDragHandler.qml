import QtQuick
import qs.modules.common

Item {
    id: root

    required property Item target
    property bool enabled: true
    property real threshold: 70
    property real dismissOvershoot: 40

    signal dismissRequested

    DragHandler {
        id: dragHandler
        target: root.target
        yAxis.enabled: false
        xAxis.enabled: true
        enabled: root.enabled

        onActiveChanged: {
            if (active)
                return;

            if (Math.abs(root.target.x) > root.threshold) {
                dismissAnim.to = root.target.x > 0
                    ? root.target.width + root.dismissOvershoot
                    : -(root.target.width + root.dismissOvershoot);
                dismissAnim.start();
            } else {
                root.target.x = 0;
            }
        }
    }

    readonly property alias dragging: dragHandler.active

    NumberAnimation {
        id: dismissAnim
        target: root.target
        property: "x"
        duration: Appearance.motion.duration.medium1
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.emphasizedAccel
        onFinished: root.dismissRequested()
    }
}
