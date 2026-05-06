pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var apps: Array.from(DesktopEntries.applications.values)
        .filter(a => !a.noDisplay)
        .filter((a, i, self) => i === self.findIndex(t => t.id === a.id))

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
