pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property list<string> entries: []

    function entryIsImage(entry) {
        return /^\d+\t\[\[.*binary.*\d+x\d+.*\]\]$/.test(entry);
    }

    function cleanText(entry) {
        return entry.replace(/^\s*\d+\s+/, "");
    }

    function refresh() {
        readBuffer.length = 0;
        readProc.running = false;
        readProc.running = true;
    }

    function fuzzyQuery(query) {
        const q = (query || "").trim().toLowerCase();
        if (q === "") return entries;
        return entries.filter(e => cleanText(e).toLowerCase().includes(q));
    }

    function copy(entry) {
        const id = entry.split("\t")[0];
        Quickshell.execDetached(["bash", "-c", `cliphist decode ${id} | wl-copy`]);
    }

    function deleteEntry(entry) {
        deleteProc.entry = entry;
        deleteProc.running = false;
        deleteProc.running = true;
    }

    property var readBuffer: []

    Process {
        id: readProc
        command: ["cliphist", "list"]
        stdout: SplitParser {
            onRead: line => root.readBuffer.push(line)
        }
        onExited: code => {
            if (code === 0) root.entries = root.readBuffer.slice();
            root.readBuffer = [];
        }
    }

    Process {
        id: deleteProc
        property string entry: ""
        command: ["bash", "-c", `printf '%s' "$ENTRY" | cliphist delete`]
        environment: ({ "ENTRY": deleteProc.entry })
        onExited: root.refresh()
    }

    Connections {
        target: Quickshell
        function onClipboardTextChanged() { refreshDebounce.restart(); }
    }

    Timer {
        id: refreshDebounce
        interval: 150
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
