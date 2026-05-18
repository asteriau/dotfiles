pragma Singleton

import QtQuick
import Quickshell
import qs.modules.common

// Single source of truth for which horizontal-bar popout (if any) is open and
// which bar item triggered it. One open at a time. Replaces the reference's
// GlobalFocusGrab + per-widget showPopup plumbing with one explicit singleton.
Singleton {
    id: root

    property string activeName: ""
    property Item triggerItem: null
    readonly property bool open: root.activeName !== ""

    // Switching popouts is close-then-open (spec v1 — no direct cross-morph).
    property string _pendingName: ""
    property Item _pendingItem: null

    function show(name, item) {
        if (root.activeName !== "" && root.activeName !== name) {
            // Different popout already open → morph the current one out, then
            // open the new one once the out-morph has finished.
            root._pendingName = name;
            root._pendingItem = item;
            root.activeName = "";   // triggerItem kept → collapses in place
            switchTimer.restart();
            return;
        }
        root.activeName = name;
        root.triggerItem = item;
    }

    // Keep triggerItem so the shape collapses back into the widget it grew
    // from (nulling it instantly makes the frame jump and kills the
    // out-animation). It is only ever overwritten by the next show().
    function close() {
        root.activeName = "";
    }

    function toggle(name, item) {
        if (root.activeName === name)
            root.close();
        else
            root.show(name, item);
    }

    Timer {
        id: switchTimer
        interval: Appearance.motion.duration.elementMove
        onTriggered: {
            root.activeName = root._pendingName;
            root.triggerItem = root._pendingItem;
            root._pendingName = "";
            root._pendingItem = null;
        }
    }
}
