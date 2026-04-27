import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.utils

PopupWindow {
    id: root

    required property var targetItem
    required property var targetRect
    required property string targetText

    color: "transparent"

    anchor {
        item: targetItem
        rect: targetRect
        margins.top: 2
        gravity: Edges.Bottom
    }

    implicitHeight: textRect.implicitHeight
    implicitWidth: textRect.implicitWidth

    WrapperRectangle {
        id: textRect

        color: Colors.background
        margin: 6
        radius: Config.layout.cardRadius / 2

        Text {
            text: root.targetText
        }
    }
}
