import QtQuick
import QtQuick.Effects
import qs.utils

// Renders a rectangle with a soft glow aura behind it.
// The glow is a blurred shadow cast by the shape, centered (no offset).
Item {
    id: root

    property real radius: width / 2
    property color color: Colors.wsGlow
    property real glowRadius: 0.8   // 0..1, how far the glow extends
    property real glowOpacity: 1.0

    Rectangle {
        id: shape
        anchors.fill: parent
        radius: root.radius
        color: root.color
        visible: false   // rendered only through MultiEffect
    }

    MultiEffect {
        source: shape
        anchors.fill: shape
        autoPaddingEnabled: true
        shadowEnabled: true
        shadowBlur: root.glowRadius
        shadowColor: root.color
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
        blurMax: 32
        opacity: root.glowOpacity
    }
}
