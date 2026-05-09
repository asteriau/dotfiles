import QtQuick
import QtQuick.Layouts
import qs.components.content
import qs.settings
import qs.utils

ContentPage {
    ContentSection {
        title: "Font"

        ContentSubsection {
            title: "Font family"

            TextFieldRow {
                objectName: "gen-fontFamily"
                text: Config.fontFamily
                onEdited: v => Config.fontFamily = v
            }
        }

        ContentSubsection {
            title: "Icon size"
            tooltip: "Material Symbols base size"

            SliderRow {
                objectName: "gen-iconSize"
                icon: "format_size"
                from: 10; to: 24; value: Config.iconSize; stepSize: 1
                suffix: "px"
                onMoved: v => Config.iconSize = v
            }
        }
    }

    ContentSection {
        title: "OSD"

        ContentSubsection {
            title: "Width"

            SliderRow {
                objectName: "gen-osdWidth"
                icon: "straighten"
                from: 100; to: 400; value: Config.osd.width; stepSize: 10
                suffix: "px"
                onMoved: v => Config.osd.width = v
            }
        }

        ContentSubsection {
            title: "Timeout"

            SliderRow {
                objectName: "gen-osdTimeout"
                icon: "timer"
                from: 500; to: 5000; value: Config.osd.timeoutMs; stepSize: 100
                suffix: "ms"
                onMoved: v => Config.osd.timeoutMs = v
            }
        }
    }
}
