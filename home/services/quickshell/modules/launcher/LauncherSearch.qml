pragma Singleton

import QtQuick
import Quickshell
import qs.modules.launcher

Singleton {
    id: root

    readonly property string clipboardPrefix: "#"

    property string query: ""

    readonly property var results: {
        if (query === "") return [];

        if (query.startsWith(clipboardPrefix)) {
            const sub = query.slice(clipboardPrefix.length);
            return Cliphist.fuzzyQuery(sub).map(e => ({
                key: "clip:" + e,
                name: Cliphist.cleanText(e),
                type: "Clipboard",
                iconType: "material",
                iconName: Cliphist.entryIsImage(e) ? "image" : "content_paste",
                verb: "Copy",
                rawValue: e,
                isImage: Cliphist.entryIsImage(e),
                execute: () => Cliphist.copy(e),
                deleteEntry: () => Cliphist.deleteEntry(e)
            }));
        }

        return AppSearch.fuzzyQuery(query).map(a => ({
            key: "app:" + a.id,
            name: a.name,
            type: "App",
            iconType: "system",
            iconName: a.icon,
            iconSource: AppSearch.iconPath(a.icon),
            verb: "Open",
            comment: a.comment || "",
            execute: () => {
                if (a.runInTerminal) {
                    Quickshell.execDetached(["foot", "-e", ...a.command]);
                } else {
                    a.execute();
                }
            }
        }));
    }
}
