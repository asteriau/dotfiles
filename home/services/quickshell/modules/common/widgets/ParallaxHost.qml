import QtQuick

Item {
    id: root

    property real parallaxX: 0
    property real parallaxY: 0
    property real maxShift: 12

    Behavior on parallaxX {
        SpringAnimation { spring: 2.6; damping: 0.32; epsilon: 0.005 }
    }
    Behavior on parallaxY {
        SpringAnimation { spring: 2.6; damping: 0.32; epsilon: 0.005 }
    }

    HoverHandler {
        id: hover
        onPointChanged: {
            if (hover.hovered) {
                const nx = (point.position.x / root.width) * 2 - 1;
                const ny = (point.position.y / root.height) * 2 - 1;
                root.parallaxX = nx * root.maxShift;
                root.parallaxY = ny * root.maxShift;
            }
        }
        onHoveredChanged: {
            if (!hovered) {
                root.parallaxX = 0;
                root.parallaxY = 0;
            }
        }
    }
}
