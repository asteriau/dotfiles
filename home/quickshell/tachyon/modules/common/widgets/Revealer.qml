import qs.modules.common
import QtQuick

/**
 * Recreation of GTK revealer. Expects one single child.
 */
Item {
    id: root
    property bool reveal
    property bool vertical: false
    clip: true

    implicitWidth: (reveal || vertical) ? childrenRect.width : 0
    implicitHeight: (reveal || !vertical) ? childrenRect.height : 0
    visible: reveal || (implicitWidth > 0 && !vertical) || (implicitHeight > 0 && vertical)

    // Direction from each Behavior's targetValue (set before the animation starts),
    // not from `reveal`, so it cannot depend on binding order
    Behavior on implicitWidth {
        id: widthBehavior
        enabled: !vertical
        animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => widthBehavior.targetValue > 0) })
    }
    Behavior on implicitHeight {
        id: heightBehavior
        enabled: vertical
        animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => heightBehavior.targetValue > 0) })
    }
}
