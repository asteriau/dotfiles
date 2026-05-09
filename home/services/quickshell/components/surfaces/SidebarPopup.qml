import QtQuick
import QtQuick.Layouts
import qs.utils

// In-sidebar overlay surface. Anchors via parent fill; show/hide animates
// via two flags (`_show` keeps the surface alive during exit, `_shown`
// drives the scale/opacity transition).
//
// Lives inside the sidebar PanelWindow rather than a separate PopupWindow
// so the sidebar's HyprlandFocusGrab doesn't dismiss it on hover. Menus
// own their own header (see MenuHeader) — this surface only paints the
// card and content slot.
Item {
    id: root

    property bool active: false
    property real padding: 12
    signal dismissed

    default property alias content: inner.data

    visible: _show
    property bool _show: false
    property bool _shown: false

    Timer {
        id: hideTimer
        interval: 200
        onTriggered: root._show = false
    }

    onActiveChanged: {
        if (active) {
            hideTimer.stop();
            _show = true;
            Qt.callLater(() => root._shown = true);
        } else {
            _shown = false;
            hideTimer.restart();
        }
    }

    // Outside-click dismiss layer — sits behind the card.
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.dismissed()
        cursorShape: Qt.ArrowCursor
    }

    Rectangle {
        id: card
        anchors.fill: parent
        color: Colors.surfaceContainer
        radius: Config.layout.cardRadius
        border.width: 1
        border.color: Colors.outlineVariant
        opacity: root._shown ? 1 : 0
        scale:   root._shown ? 1 : 0.96
        transformOrigin: Item.Center

        Behavior on opacity { Motion.Fade {} }
        Behavior on scale   { Motion.Spatial {} }

        // Eat clicks inside the card so the outside-click MouseArea below
        // doesn't fire when interacting with menu rows.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onPressed: (mouse) => mouse.accepted = true
            cursorShape: Qt.ArrowCursor
            propagateComposedEvents: true
        }

        Item {
            id: inner
            anchors.fill: parent
            anchors.margins: root.padding
        }
    }
}
