import QtQuick
import QtQuick.Layouts
import qs.components.content
import qs.components.controls
import qs.settings
import qs.utils

ContentPage {
    ContentSection {
        title: "Position"
        icon: "dock_to_left"

        ContentSubsection {
            title: "Bar position"

            SegmentedControl {
                currentValue: Config.bar.position
                onSelectedValue: v => Config.bar.position = v
                options: [
                    { label: "Left",   icon: "arrow_back",     value: "left"   },
                    { label: "Right",  icon: "arrow_forward",  value: "right"  },
                    { label: "Top",    icon: "arrow_upward",   value: "top"    },
                    { label: "Bottom", icon: "arrow_downward", value: "bottom" }
                ]
            }
        }
    }

    ContentSection {
        title: "Dimensions"
        icon: "straighten"

        ContentSubsection {
            title: "Sidebar width"

            SliderRow {
                icon: "view_sidebar"
                from: 300; to: 600; value: Config.sidebar.width; stepSize: 10
                suffix: "px"
                onMoved: v => Config.sidebar.width = v
            }
        }
    }

    ContentSection {
        title: "Workspaces"
        icon: "grid_view"

        ContentSubsection {
            title: "Workspaces shown"

            SliderRow {
                icon: "grid_4x4"
                from: 4; to: 20; value: Config.workspaces.shown; stepSize: 1
                onMoved: v => Config.workspaces.shown = v
            }
        }

        SwitchRow {
            text: "Show app icons"
            icon: "apps"
            checked: Config.workspaces.showAppIcons
            onToggled: v => Config.workspaces.showAppIcons = v
        }

        SwitchRow {
            text: "Always show numbers"
            icon: "format_list_numbered"
            checked: Config.workspaces.alwaysShowNumbers
            onToggled: v => Config.workspaces.alwaysShowNumbers = v
        }

        SwitchRow {
            text: "Monochrome icons"
            icon: "filter_b_and_w"
            checked: Config.workspaces.monochromeIcons
            onToggled: v => Config.workspaces.monochromeIcons = v
        }
    }
}
