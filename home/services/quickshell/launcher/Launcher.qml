import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.launcher
import qs.utils

Scope {
    id: scope

    property bool open: false
    property bool _superMayTrigger: false

    function show() {
        open = true;
    }
    function hide() {
        open = false;
    }
    function toggle() {
        open = !open;
    }

    onOpenChanged: {
        if (open) {
            searchWidget.enableExpandAnimation();
            searchWidget.clear();
            Qt.callLater(() => searchWidget.focusInput());
        } else {
            searchWidget.disableExpandAnimation();
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { scope.toggle(); }
        function open(): void { scope.show(); }
        function close(): void { scope.hide(); }
        function clipboardToggle(): void {
            if (scope.open && searchWidget.query.startsWith(LauncherSearch.clipboardPrefix)) {
                scope.hide();
            } else {
                scope.open = true;
                Qt.callLater(() => searchWidget.setText(LauncherSearch.clipboardPrefix));
            }
        }
    }

    PanelWindow {
        id: panel
        screen: Config.preferredMonitor
        visible: scope.open

        WlrLayershell.namespace: "quickshell:launcher"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: scope.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        color: "transparent"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        mask: Region {
            item: scope.open ? searchWidget : null
        }

        HyprlandFocusGrab {
            windows: [panel]
            active: scope.open
            onCleared: scope.hide()
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                scope.hide();
                event.accepted = true;
            } else if (event.key === Qt.Key_Down) {
                searchWidget.listView.incrementCurrentIndex();
                event.accepted = true;
            } else if (event.key === Qt.Key_Up) {
                searchWidget.listView.decrementCurrentIndex();
                event.accepted = true;
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                const cur = searchWidget.listView.currentItem;
                if (cur) {
                    cur.activated();
                    event.accepted = true;
                }
            }
        }

        SearchWidget {
            id: searchWidget
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: (Config.bar.position === "top" ? Config.bar.height : 0) + 80
            onActivated: scope.hide()
        }

        Shortcut {
            sequences: ["Escape"]
            enabled: scope.open
            onActivated: scope.hide()
        }
    }

    GlobalShortcut {
        name: "searchToggleRelease"
        onPressed: scope._superMayTrigger = true
        onReleased: {
            if (scope._superMayTrigger) {
                scope.toggle();
            }
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
            if (scope.open && searchWidget.query.startsWith(LauncherSearch.clipboardPrefix)) {
                scope.hide();
            } else {
                scope.open = true;
                Qt.callLater(() => searchWidget.setText(LauncherSearch.clipboardPrefix));
            }
        }
    }
}
