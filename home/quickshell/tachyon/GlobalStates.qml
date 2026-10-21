import qs.modules.common
import qs.services
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
pragma Singleton
pragma ComponentBehavior: Bound

Singleton {
    id: root
    property bool barOpen: true
    property bool crosshairOpen: false
    property bool sidebarLeftOpen: false
    property bool sidebarRightOpen: false
    property bool mediaControlsOpen: false
    property bool osdBrightnessOpen: false
    property bool osdVolumeOpen: false
    property bool oskOpen: false
    property bool overlayOpen: false
    property bool overviewOpen: false
    property bool regionSelectorOpen: false
    property bool searchOpen: false
    property bool screenLocked: false
    property bool screenLockContainsCharacters: false
    property bool screenUnlockFailed: false
    property bool screenTranslatorOpen: false
    property bool sessionOpen: false
    property bool superDown: false
    property bool superReleaseMightTrigger: true
    property bool wallpaperSelectorOpen: false
    property bool workspaceShowNumbers: false

    // Super release toggles search unless something else happened while it was
    // held. Hyprland's catchall bind cannot report that (it only fires for keys
    // no other bind matched), so the shell watches its own toggles and the
    // compositor's events instead.
    function cancelSuperRelease() {
        if (root.superDown)
            root.superReleaseMightTrigger = false;
    }
    onBarOpenChanged: cancelSuperRelease()
    onCrosshairOpenChanged: cancelSuperRelease()
    onSidebarLeftOpenChanged: cancelSuperRelease()
    onMediaControlsOpenChanged: cancelSuperRelease()
    onOskOpenChanged: cancelSuperRelease()
    onOverlayOpenChanged: cancelSuperRelease()
    onOverviewOpenChanged: cancelSuperRelease()
    onRegionSelectorOpenChanged: cancelSuperRelease()
    onSearchOpenChanged: cancelSuperRelease()
    onScreenTranslatorOpenChanged: cancelSuperRelease()
    onSessionOpenChanged: cancelSuperRelease()
    onWallpaperSelectorOpenChanged: cancelSuperRelease()
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            // layer events also come from hover popups, which are not key presses
            if (!event.name.endsWith("layer"))
                root.cancelSuperRelease();
        }
    }

    onSidebarRightOpenChanged: {
        cancelSuperRelease();
        if (GlobalStates.sidebarRightOpen) {
            Notifications.timeoutAll();
            Notifications.markAllRead();
        }
    }

    GlobalShortcut {
        name: "workspaceNumber"
        description: "Hold to show workspace numbers, release to show icons"

        onPressed: {
            root.superDown = true
        }
        onReleased: {
            root.superDown = false
        }
    }
}