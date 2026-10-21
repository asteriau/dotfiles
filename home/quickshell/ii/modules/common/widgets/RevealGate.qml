import QtQuick
import qs.modules.common

/**
 * Keeps a Loader or window alive for one exit duration after `shown` goes
 * false, so a RevealSurface inside it can finish leaving.
 * Bind Loader.active / PanelWindow.visible to `active`.
 */
QtObject {
    id: root
    property bool shown: false
    readonly property bool active: shown || exitTimer.running

    property Timer exitTimer: Timer {
        interval: Appearance.animation.exit.duration
    }
    onShownChanged: shown ? exitTimer.stop() : exitTimer.restart()
}
