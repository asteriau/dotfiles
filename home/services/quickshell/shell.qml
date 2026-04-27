//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import qs.bar
import qs.notifications
import qs.osd
import qs.settings
import qs.sidebar
import qs.utils
import Quickshell // for ShellRoot and PanelWindow
import Quickshell.Hyprland // for GlobalShortcut

ShellRoot {
    Bar {}
    NotificationOverlay {}
    OSD {}
    Sidebar {}
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
