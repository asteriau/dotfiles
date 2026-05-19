import QtQuick
import qs.modules.common
import qs.modules.sidebar.quickToggles.models

QuickToggleModel {
    readonly property bool isDark: Config.theme.mode === "matugen" ? Config.theme.matugen.dark : (
                                                                         Config.theme.preset
                                                                         !== "default-light")
    name: "Dark Mode"
    icon: isDark ? "dark_mode" : "light_mode"
    statusText: isDark ? "Dark" : "Light"
    tooltipText: "Dark Mode"
    toggled: isDark
    hasMenu: false
    mainAction: () => {
                    if (Config.theme.mode === "matugen") {
                        Config.theme.matugen.dark = !Config.theme.matugen.dark;
                    } else {
                        Config.theme.preset = isDark ? "default-light" : "default-dark";
                    }
                }
}
