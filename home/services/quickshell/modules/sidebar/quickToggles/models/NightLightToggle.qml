import QtQuick
import qs.services
import qs.modules.sidebar.quickToggles.models

QuickToggleModel {
    readonly property bool on: NightLight.active
    name: "Night Light"
    icon: on ? "bedtime" : "bedtime_off"
    statusText: on ? "Active" : "Inactive"
    tooltipText: "Night Light"
    toggled: on
    hasMenu: false
    mainAction: () => NightLight.setTemperature(NightLight.active ? NightLight.maxTemp : 4000)
}
