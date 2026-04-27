import QtQuick
import QtQuick.Effects
import qs.components.shape

// Cumulus cluster: shadow + five Puffy body bubbles + sun-lit highlight puff.
// Extracted from CloudsScene so Thunder and Clouds can reuse one definition.
Item {
    id: cluster

    property real cloudSize: 120
    property color tint:          "white"
    property color highlightTint: "white"
    property color shadowTint:    Qt.rgba(0, 0, 0, 0.16)

    width: cloudSize * 1.7
    height: cloudSize * 1.0

    // Underside soft shadow
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: cluster.cloudSize * 0.2
        width: cluster.cloudSize * 1.4
        height: cluster.cloudSize * 0.55
        radius: height / 2
        color: cluster.shadowTint
    }

    // Five Puffy bubbles forming the body arc (lowest center, higher edges)
    MaterialShape { x: cluster.cloudSize * 0.00; y: cluster.cloudSize * 0.32; implicitSize: cluster.cloudSize * 0.55; shape: MaterialShape.Shape.Puffy; color: cluster.tint }
    MaterialShape { x: cluster.cloudSize * 0.25; y: cluster.cloudSize * 0.18; implicitSize: cluster.cloudSize * 0.78; shape: MaterialShape.Shape.Puffy; color: cluster.tint }
    MaterialShape { x: cluster.cloudSize * 0.55; y: cluster.cloudSize * 0.05; implicitSize: cluster.cloudSize * 0.92; shape: MaterialShape.Shape.Puffy; color: cluster.tint }
    MaterialShape { x: cluster.cloudSize * 0.95; y: cluster.cloudSize * 0.18; implicitSize: cluster.cloudSize * 0.75; shape: MaterialShape.Shape.Puffy; color: cluster.tint }
    MaterialShape { x: cluster.cloudSize * 1.18; y: cluster.cloudSize * 0.32; implicitSize: cluster.cloudSize * 0.55; shape: MaterialShape.Shape.Puffy; color: cluster.tint }

    // Sun-lit highlight puff
    MaterialShape {
        x: cluster.cloudSize * 0.6
        y: -cluster.cloudSize * 0.02
        implicitSize: cluster.cloudSize * 0.62
        shape: MaterialShape.Shape.Puffy
        color: cluster.highlightTint
        opacity: 0.55
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        blurEnabled: true
        blur: 0.12
        blurMax: 6
        shadowEnabled: true
        shadowBlur: 0.9
        shadowOpacity: 0.28
        shadowVerticalOffset: 10
        shadowColor: "#000000"
    }
}
