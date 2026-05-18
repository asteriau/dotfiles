pragma Singleton

import QtQuick
import Quickshell

// Single source of truth for which horizontal-bar popout (if any) is open and
// which bar item triggered it. One open at a time. Replaces the reference's
// GlobalFocusGrab + per-widget showPopup plumbing with one explicit singleton.
Singleton {
    id: root

    property string activeName: ""
    property Item triggerItem: null
    readonly property bool open: root.activeName !== ""

    function show(name, item) {
        root.activeName = name;
        root.triggerItem = item;
    }

    function close() {
        root.activeName = "";
        root.triggerItem = null;
    }

    function toggle(name, item) {
        if (root.activeName === name)
            root.close();
        else
            root.show(name, item);
    }
}
