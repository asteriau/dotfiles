pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var apps: {
        const seen = new Set();
        const out = [];
        const values = DesktopEntries.applications.values;
        for (let i = 0; i < values.length; i++) {
            const a = values[i];
            if (a.noDisplay) continue;
            if (seen.has(a.id)) continue;
            seen.add(a.id);
            out.push(a);
        }
        return out;
    }

    // Memoize Quickshell.iconPath. On NixOS XDG_DATA_DIRS expands across many
    // /nix/store icon-theme paths, so each cold lookup is slow enough to
    // stutter the UI thread when 15 delegates resolve icons in a single
    // keystroke. Cached path is what feeds IconImage.source downstream.
    property var _iconCache: ({})
    function iconPath(name) {
        if (!name) return "";
        const hit = _iconCache[name];
        if (hit !== undefined) return hit;
        const p = Quickshell.iconPath(name, "application-x-executable");
        _iconCache[name] = p;
        return p;
    }

    // Pre-warm apps list + icon cache after startup so the first keystroke
    // doesn't pay for the initial scan, dedup, and 400+ icon resolutions.
    Component.onCompleted: {
        const list = root.apps;
        for (let i = 0; i < list.length; i++) iconPath(list[i].icon);
    }

    function _score(name, query) {
        if (!query) return 1;
        const n = name.toLowerCase();
        const q = query.toLowerCase();
        if (n === q) return 1000;
        if (n.startsWith(q)) return 500 - n.length;
        const idx = n.indexOf(q);
        if (idx >= 0) return 300 - idx - n.length * 0.1;
        // subsequence
        let qi = 0, last = -1, gaps = 0;
        for (let i = 0; i < n.length && qi < q.length; i++) {
            if (n[i] === q[qi]) {
                if (last >= 0) gaps += i - last - 1;
                last = i;
                qi++;
            }
        }
        if (qi < q.length) return -1;
        return 100 - gaps - n.length * 0.05;
    }

    function fuzzyQuery(query) {
        if (!query || query.trim() === "") return apps;
        const scored = apps.map(a => ({ app: a, score: _score(a.name, query) }))
            .filter(x => x.score > 0);
        scored.sort((a, b) => b.score - a.score);
        return scored.map(x => x.app);
    }
}
