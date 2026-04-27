import QtQuick

// Wraps children in an Item that translates by `parallaxX/Y * depth`.
// Replaces the 20+ copies of `Item { transform: Translate { x: scene.parallaxX * d } }`
// found across weather scenes.
Item {
    id: root

    property real parallaxX: 0
    property real parallaxY: 0
    property real depth: 0.4
    // Allow asymmetric Y depth (used by Sunny: clouds use depthY=0.3 with depth=0.5).
    property real depthY: depth

    anchors.fill: parent

    transform: Translate {
        x: root.parallaxX * root.depth
        y: root.parallaxY * root.depthY
    }
}
