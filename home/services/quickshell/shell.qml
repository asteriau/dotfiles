//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import qs.background
import qs.bar
import qs.island
import qs.launcher
import qs.screenshot
import qs.settings
import qs.sidebar
import qs.utils
import qs.wallpaper
import Quickshell // for ShellRoot and PanelWindow
import Quickshell.Hyprland // for GlobalShortcut

ShellRoot {
    // Keep MatugenState alive so its Connections auto-regen on wallpaper/scheme changes
    readonly property var _matugen: MatugenState

    Background {}
    Bar {}
    Launcher { id: launcher }
    Island { launcher: launcher }
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
        onTriggered: Config.showWorkspaceNumbers = true
    }

    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            showNumbersTimer.restart()
        }
        onReleased: {
            showNumbersTimer.stop()
            Config.showWorkspaceNumbers = false
        }
    }
}
