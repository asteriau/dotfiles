//@ pragma UseQApplication
import QtQuick
import qs.bar
import qs.notifications
import qs.osd
import qs.sidebar
import qs.utils
import Quickshell // for ShellRoot and PanelWindow
import Quickshell.Hyprland // for GlobalShortcut

ShellRoot {
    Bar {}
    NotificationOverlay {}
    OSD {}
    Sidebar {}

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
