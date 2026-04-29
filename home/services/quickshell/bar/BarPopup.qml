import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.utils

// Hover/click popup for bar widgets. Adapted from ii's StyledPopup.
// Toggle via `active`. Default children become popup content.
//
// `transparent: true` disables the inner surface so callers can supply their
// own card chrome (e.g. MediaCard).
PopupWindow {
    id: root

    required property Item targetItem
    property bool active: false
    property bool transparent: false
    property real padding: 10
    default property alias content: inner.data

    color: "transparent"
    visible: _show

    property bool _show: false
    property bool _shown: false

    // Two flags: `_show` keeps the surface alive during the exit animation;
    // `_shown` drives the scale/opacity reveal. Qt.callLater on entry lets the
    // surface map at the small/zero state before transitioning to full.
    Timer {
        id: hideTimer
        interval: 200
        onTriggered: root._show = false
    }

    onActiveChanged: {
        if (active) {
            hideTimer.stop()
            _show = true
            Qt.callLater(() => root._shown = true)
        } else {
            _shown = false
            hideTimer.restart()
        }
    }

    anchor {
        item: root.targetItem
        rect: Qt.rect(
            Config.bar.vertical 
                ? (root.targetItem.width / 2) + (Config.bar.onEnd ? -(Config.bar.width / 2 + 8) : (Config.bar.width / 2 + 8))
                : root.targetItem.width / 2,
            Config.bar.vertical 
                ? root.targetItem.height / 2 
                : (root.targetItem.height / 2) + (Config.bar.onEnd ? -(Config.bar.height / 2 + 8) : (Config.bar.height / 2 + 8)),
            0, 0
        )
        gravity: Config.bar.vertical 
            ? (Config.bar.onEnd ? Edges.Left : Edges.Right) 
            : (Config.bar.onEnd ? Edges.Top : Edges.Bottom)
    }

    implicitWidth:  inner.childrenRect.width  + (root.transparent ? 0 : root.padding * 2)
    implicitHeight: inner.childrenRect.height + (root.transparent ? 0 : root.padding * 2)

    Item {
        id: animWrap
        anchors.fill: parent
        opacity: root._shown ? 1 : 0
        scale:   root._shown ? 1 : 0.92
        transformOrigin: Config.bar.vertical ? Item.Left : Item.Top

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 200
                easing.type: Easing.BezierSpline
                easing.bezierCurve: [0.34, 0.80, 0.34, 1.00, 1, 1]
            }
        }

        Rectangle {
            id: bg
            anchors.fill: parent
            visible: !root.transparent
            color: Colors.surfaceContainer
            radius: Config.layout.radiusSm
            border.width: 1
            border.color: Colors.outlineVariant
        }

        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: root.transparent ? 0 : root.padding
        }
    }
}
