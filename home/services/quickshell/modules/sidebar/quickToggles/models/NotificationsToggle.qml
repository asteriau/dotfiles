import QtQuick
import qs.modules.common
import qs.modules.sidebar.quickToggles.models

QuickToggleModel {
    readonly property bool dnd: Config.notifications.doNotDisturb
    name: "Do Not Disturb"
    icon: dnd ? "do_not_disturb_on" : "do_not_disturb_off"
    statusText: dnd ? "Silent" : "On"
    tooltipText: "Do Not Disturb"
    toggled: dnd
    hasMenu: false
    mainAction: () => Config.notifications.doNotDisturb = !Config.notifications.doNotDisturb
}
