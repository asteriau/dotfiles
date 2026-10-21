pragma Singleton

import Quickshell

// Session-scoped query for the keybind cheatsheet. Kept here on purpose:
// the filter survives closing and reopening the cheatsheet within a session,
// and resets whenever the quickshell process restarts.
Singleton {
    id: root
    property string query: ""
}
