import QtQuick
import QtQuick.Layouts
import qs.components.content
import qs.settings
import qs.utils

ContentPage {
    ContentSection {
        title: "Behaviour"
        icon: "tune"

        SwitchRow {
            text: "Do not disturb"
            caption: "Silence toasts; history still captured"
            icon: "do_not_disturb_on"
            checked: Config.doNotDisturb
            onToggled: v => Config.doNotDisturb = v
        }
    }

    ContentSection {
        title: "Font"
        icon: "text_fields"

        ContentSubsection {
            title: "Font family"

            TextFieldRow {
                text: Config.fontFamily
                onEdited: v => Config.fontFamily = v
            }
        }

        ContentSubsection {
            title: "Icon size"
            tooltip: "Material Symbols base size"

            SliderRow {
                icon: "format_size"
                from: 10; to: 24; value: Config.iconSize; stepSize: 1
                suffix: "px"
                onMoved: v => Config.iconSize = v
            }
        }
    }

    ContentSection {
        title: "OSD"
        icon: "volume_up"

        ContentSubsection {
            title: "Width"

            SliderRow {
                icon: "straighten"
                from: 100; to: 400; value: Config.osdWidth; stepSize: 10
                suffix: "px"
                onMoved: v => Config.osdWidth = v
            }
        }

        ContentSubsection {
            title: "Timeout"

            SliderRow {
                icon: "timer"
                from: 500; to: 5000; value: Config.osdTimeoutMs; stepSize: 100
                suffix: "ms"
                onMoved: v => Config.osdTimeoutMs = v
            }
        }
    }
}
