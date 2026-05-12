//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import qs.modules.background
import qs.modules.bar
import qs.modules.island
import qs.modules.launcher
import qs.modules.notifications.popup
import qs.modules.screenshot
import qs.modules.settings
import qs.modules.sidebar
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.modules.wallpaper
import qs.services
import Quickshell
import Quickshell.Hyprland

ShellRoot {
    readonly property var _matugen: Matugen

    Background {}
    Bar {}
    Launcher { id: launcher }
    Island { launcher: launcher }
    NotificationPopups {}
    Sidebar {}
    WallpaperPicker {}
    RegionSelector {}
    // Settings window
    property var _settingsWindow: null
    Connections {
        target: Utils
        function onSettingsRequested() {
            if (_settingsWindow) {
                _settingsWindow.raise();
                _settingsWindow.requestActivate();
                return;
            }
            _settingsWindow = settingsComponent.createObject(null);
            _settingsWindow.closing.connect(function() {
                _settingsWindow.destroy();
                _settingsWindow = null;
            });
        }
    }

    Component {
        id: settingsComponent
        Settings {}
    }

    // Super key hold → reveal workspace numbers
    Timer {
        id: showNumbersTimer
        interval: 100
        repeat: false
        onTriggered: UiState.showWorkspaceNumbers = true
    }

    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            showNumbersTimer.restart()
        }
        onReleased: {
            showNumbersTimer.stop()
            UiState.showWorkspaceNumbers = false
        }
    }
}
