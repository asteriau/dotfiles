import QtQuick
import Quickshell
import qs.utils

PopupWindow {
    id: root

    required property var targetItem
    required property var targetRect
    required property string targetText
    property bool shown: false

    color: "transparent"

    anchor {
        item: targetItem
        rect: targetRect
        margins.top: 2
        gravity: Edges.Bottom
    }

    implicitWidth:  label.implicitWidth  + 20
    implicitHeight: label.implicitHeight + 10

    // Reset and re-arm the reveal each time the surface maps. Setting `shown`
    // on the next tick lets the bg paint at scale 0.92/opacity 0 before the
    // Behaviors animate it in.
    onVisibleChanged: {
        if (visible) {
            shown = false
            Qt.callLater(() => root.shown = true)
        } else {
            shown = false
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: Appearance.colors.tooltipBg
        radius: Appearance.layout.radiusSm
        opacity: root.shown ? 1 : 0
        scale:   root.shown ? 1 : 0.92
        transformOrigin: Item.Top

        Behavior on opacity {
            NumberAnimation { duration: 140 }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
            }
        }

        Text {
            id: label
            anchors.centerIn: parent
            text: root.targetText
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.smaller
            font.hintingPreference: Font.PreferNoHinting
            color: Appearance.colors.tooltipFg
        }
    }
}
