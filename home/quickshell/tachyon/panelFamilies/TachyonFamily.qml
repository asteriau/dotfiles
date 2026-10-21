import QtQuick
import Quickshell

import qs.modules.common
import qs.modules.tachyon.background
import qs.modules.tachyon.bar
import qs.modules.tachyon.cheatsheet
import qs.modules.tachyon.dock
import qs.modules.tachyon.lock
import qs.modules.tachyon.mediaControls
import qs.modules.tachyon.notificationPopup
import qs.modules.tachyon.onScreenDisplay
import qs.modules.tachyon.onScreenKeyboard
import qs.modules.tachyon.overview
import qs.modules.tachyon.polkit
import qs.modules.tachyon.regionSelector
import qs.modules.tachyon.screenCorners
import qs.modules.tachyon.screenTranslator
import qs.modules.tachyon.sessionScreen
import qs.modules.tachyon.sidebarLeft
import qs.modules.tachyon.sidebarRight
import qs.modules.tachyon.overlay
import qs.modules.tachyon.verticalBar
import qs.modules.tachyon.wallpaperSelector

Scope {
    PanelLoader { extraCondition: !Config.options.bar.vertical; component: Bar {} }
    PanelLoader { component: Background {} }
    PanelLoader { component: Cheatsheet {} }
    PanelLoader { extraCondition: Config.options.dock.enable; component: Dock {} }
    PanelLoader { component: Lock {} }
    PanelLoader { component: MediaControls {} }
    PanelLoader { component: NotificationPopup {} }
    PanelLoader { component: OnScreenDisplay {} }
    PanelLoader { component: OnScreenKeyboard {} }
    PanelLoader { component: Overlay {} }
    PanelLoader { component: Overview {} }
    PanelLoader { component: Polkit {} }
    PanelLoader { component: RegionSelector {} }
    PanelLoader { component: ScreenCorners {} }
    PanelLoader { component: ScreenTranslator {} }
    PanelLoader { component: SessionScreen {} }
    PanelLoader { component: SidebarLeft {} }
    PanelLoader { component: SidebarRight {} }
    PanelLoader { extraCondition: Config.options.bar.vertical; component: VerticalBar {} }
    PanelLoader { component: WallpaperSelector {} }
}
