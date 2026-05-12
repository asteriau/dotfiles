pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string shellDir: {
        const u = Qt.resolvedUrl("../..").toString();
        return u.replace(/^file:\/\//, "").replace(/\/$/, "");
    }

    readonly property string scriptPath:        shellDir + "/scripts"
    readonly property string recordScriptPath:  shellDir + "/scripts/record.sh"
    readonly property string screenshotTemp:    "/tmp/quickshell/screenshot"
}
