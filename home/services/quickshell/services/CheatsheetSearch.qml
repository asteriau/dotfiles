pragma Singleton

import Quickshell

// Session-scoped query for the keybind cheatsheet. Kept here on purpose. 
// the filter should survive closing and reopening the cheatsheet within a session, but reset whenever the quickshell process restarts.

Singleton {
    id: root
    property string query: ""
}
