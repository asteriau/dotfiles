pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

Scope {
    id: root

    function dismiss() {
        ScreenshotState.regionSelectorOpen = false;
    }

    property var action: RegionSelection.SnipAction.Copy
    property var selectionMode: RegionSelection.SelectionMode.RectCorners

    function _open() {
        ScreenshotState.regionSelectorOpen = true;
    }

    function screenshot() {
        root.action = RegionSelection.SnipAction.Copy;
        root.selectionMode = RegionSelection.SelectionMode.RectCorners;
        _open();
    }

    function record() {
        root.action = RegionSelection.SnipAction.Record;
        root.selectionMode = RegionSelection.SelectionMode.RectCorners;
        if (ScreenshotState.regionSelectorOpen) ScreenshotState.regionSelectorOpen = false;
        _open();
    }

    function recordWithSound() {
        root.action = RegionSelection.SnipAction.RecordWithSound;
        root.selectionMode = RegionSelection.SelectionMode.RectCorners;
        if (ScreenshotState.regionSelectorOpen) ScreenshotState.regionSelectorOpen = false;
        _open();
    }

    Variants {
        model: Quickshell.screens
        delegate: LazyLoader {
            id: regionSelectorLoader
            required property var modelData
            active: ScreenshotState.regionSelectorOpen

            component: RegionSelection {
                screen: regionSelectorLoader.modelData
                onDismiss: root.dismiss()
                action: root.action
                selectionMode: root.selectionMode
            }
        }
    }

    IpcHandler {
        target: "region"
        function screenshot() { root.screenshot(); }
        function record() { root.record(); }
        function recordWithSound() { root.recordWithSound(); }
    }

    GlobalShortcut {
        name: "regionScreenshot"
        description: "Takes a screenshot of the selected region"
        onPressed: root.screenshot()
    }
    GlobalShortcut {
        name: "regionRecord"
        description: "Records the selected region"
        onPressed: root.record()
    }
    GlobalShortcut {
        name: "regionRecordWithSound"
        description: "Records the selected region with sound"
        onPressed: root.recordWithSound()
    }
}
