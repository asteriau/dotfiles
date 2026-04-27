import QtQuick
import QtQuick.Layouts
import qs.utils
import qs.components
import qs.settings

ContentPage {
    ContentSection {
        title: "Position"
        icon: "dock_to_left"

        ContentSubsection {
            title: "Bar position"

            SegmentedControl {
                currentValue: Config.barPosition
                onSelectedValue: v => Config.barPosition = v
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
            title: "Bar height"

            SliderRow {
                icon: "height"
                from: 24; to: 64; value: Config.barHeight; stepSize: 2
                suffix: "px"
                onMoved: v => Config.barHeight = v
            }
        }

        ContentSubsection {
            title: "Bar width"

            SliderRow {
                icon: "width_normal"
                from: 36; to: 80; value: Config.barWidth; stepSize: 2
                suffix: "px"
                onMoved: v => Config.barWidth = v
            }
        }

        ContentSubsection {
            title: "Sidebar width"

            SliderRow {
                icon: "view_sidebar"
                from: 300; to: 600; value: Config.sidebarWidth; stepSize: 10
                suffix: "px"
                onMoved: v => Config.sidebarWidth = v
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
                from: 4; to: 20; value: Config.workspacesShown; stepSize: 1
                onMoved: v => Config.workspacesShown = v
            }
        }

        SwitchRow {
            text: "Show app icons"
            icon: "apps"
            checked: Config.workspaceShowAppIcons
            onToggled: v => Config.workspaceShowAppIcons = v
        }

        SwitchRow {
            text: "Always show numbers"
            icon: "format_list_numbered"
            checked: Config.workspaceAlwaysShowNumbers
            onToggled: v => Config.workspaceAlwaysShowNumbers = v
        }

        SwitchRow {
            text: "Monochrome icons"
            icon: "filter_b_and_w"
            checked: Config.workspaceMonochromeIcons
            onToggled: v => Config.workspaceMonochromeIcons = v
        }
    }
}
