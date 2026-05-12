pragma Singleton

import QtQuick
import Quickshell
import qs.modules.common

Singleton {
    id: root

    property bool regionSelectorOpen: false

    enum Action {
        Copy,
        Record,
        RecordWithSound
    }

    function _esc(s) { return String(s).replace(/'/g, "'\\''"); }

    function getCommand(x, y, width, height, screenshotPath, action, saveDir = "") {
        const rx = Math.round(x);
        const ry = Math.round(y);
        const rw = Math.round(width);
        const rh = Math.round(height);
        const cropBase = `magick '${_esc(screenshotPath)}' -crop ${rw}x${rh}+${rx}+${ry} +repage`;
        const cropToStdout = `${cropBase} -`;
        const cleanup = `rm '${_esc(screenshotPath)}'`;
        const slurpRegion = `${rx},${ry} ${rw}x${rh}`;

        switch (action) {
            case Screenshot.Action.Copy:
                if (saveDir === "") {
                    return ["bash", "-c", `${cropToStdout} | wl-copy && ${cleanup}`];
                }
                return [
                    "bash", "-c",
                    `mkdir -p '${_esc(saveDir)}' && \
                    saveFileName="screenshot-$(date '+%Y-%m-%d_%H.%M.%S').png" && \
                    savePath='${_esc(saveDir)}'/"$saveFileName" && \
                    ${cropToStdout} | tee >(wl-copy) > "$savePath" && \
                    ${cleanup}`
                ];
            case Screenshot.Action.Record:
                return ["bash", "-c", `'${_esc(Directories.recordScriptPath)}' --region '${slurpRegion}'`];
            case Screenshot.Action.RecordWithSound:
                return ["bash", "-c", `'${_esc(Directories.recordScriptPath)}' --region '${slurpRegion}' --sound`];
            default:
                console.warn("[Screenshot] Unknown action:", action);
                return null;
        }
    }
}
