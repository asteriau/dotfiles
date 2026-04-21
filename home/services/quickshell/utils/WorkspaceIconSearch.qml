pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property var substitutions: ({
        "code-url-handler": "visual-studio-code",
        "Code": "visual-studio-code",
        "gnome-tweaks": "org.gnome.tweaks",
        "pavucontrol-qt": "pavucontrol",
        "footclient": "foot",
    })

    function iconExists(name) {
        if (!name || name.length === 0) return false;
        const p = Quickshell.iconPath(name, true);
        return p.length > 0 && !p.includes("image-missing");
    }

    function guessIcon(str) {
        if (!str || str.length === 0) return "image-missing";
        if (substitutions[str]) return substitutions[str];
        if (substitutions[str.toLowerCase()]) return substitutions[str.toLowerCase()];
        const entry = DesktopEntries.byId(str);
        if (entry) return entry.icon;
        if (iconExists(str)) return str;
        const lower = str.toLowerCase();
        if (iconExists(lower)) return lower;
        const heuristic = DesktopEntries.heuristicLookup(str);
        if (heuristic) return heuristic.icon;
        return "application-x-executable";
    }
}
