import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.modules.launcher

Scope {
    id: scope

    property bool open: false
    property bool _superMayTrigger: false

    // Set by Island.qml so we can drive the embedded LauncherMode view
    // (focus input, clear/set text on open, etc.).
    property var islandView: null

    function show() { open = true; }
    function hide() { open = false; }
    function toggle() { open = !open; }

    onOpenChanged: {
        if (open) {
            if (islandView) {
                islandView.clear();
                Qt.callLater(() => islandView.focusInput());
            }
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { scope.toggle(); }
        function open(): void { scope.show(); }
        function close(): void { scope.hide(); }
        function clipboardToggle(): void {
            if (scope.open && LauncherSearch.query.startsWith(LauncherSearch.clipboardPrefix)) {
                scope.hide();
            } else {
                scope.open = true;
                Qt.callLater(() => {
                    if (scope.islandView) scope.islandView.setText(LauncherSearch.clipboardPrefix);
                });
            }
        }
    }

    GlobalShortcut {
        name: "searchToggleRelease"
        onPressed: scope._superMayTrigger = true
        onReleased: {
            if (scope._superMayTrigger) scope.toggle();
            scope._superMayTrigger = true;
        }
    }

    GlobalShortcut {
        name: "searchToggleReleaseInterrupt"
        onPressed: scope._superMayTrigger = false
    }

    GlobalShortcut {
        name: "launcherToggle"
        onPressed: scope.toggle()
    }

    GlobalShortcut {
        name: "launcherClipboardToggle"
        onPressed: {
            if (scope.open && LauncherSearch.query.startsWith(LauncherSearch.clipboardPrefix)) {
                scope.hide();
            } else {
                scope.open = true;
                Qt.callLater(() => {
                    if (scope.islandView) scope.islandView.setText(LauncherSearch.clipboardPrefix);
                });
            }
        }
    }
}
