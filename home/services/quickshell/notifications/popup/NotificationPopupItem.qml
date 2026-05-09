pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.notifications
import qs.utils
import qs.services

// Per-popup wrapper around NotificationBox. Adds auto-dismiss timer with
// hover-pause; critical urgency is sticky.
Item {
    id: root

    property var n
    readonly property bool isCritical: (n?.urgency ?? NotificationUrgency.Normal) === NotificationUrgency.Critical

    implicitHeight: card.implicitHeight
    height: implicitHeight

    HoverHandler {
        id: hover
    }

    Timer {
        id: dismissTimer
        interval: Config.notifications.expireTimeout
        running: !root.isCritical && !hover.hovered && root.n !== null
        repeat: false
        onTriggered: {
            if (root.n) NotificationState.notifDismissByNotif(root.n);
        }
    }

    NotificationBox {
        id: card
        anchors.left: parent.left
        anchors.right: parent.right
        n: root.n
        isPopup: true
    }
}
