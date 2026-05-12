import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common

ContentSection {
    id: root

    title: "Matugen"

    ContentSubsection {
        title: "Color scheme"

        Item {
            Layout.fillWidth: true
            Layout.leftMargin: Appearance.layout.gapXl
            Layout.rightMargin: Appearance.layout.gapXl
            Layout.bottomMargin: 6
            implicitHeight: schemeSeg.implicitHeight

            SegmentedControl {
                id: schemeSeg
                objectName: "theme-matugenScheme"
                anchors.left: parent.left
                anchors.right: parent.right
                currentValue: Config.theme.matugen.scheme
                options: [
                    { label: "Tonal Spot",  value: "scheme-tonal-spot"  },
                    { label: "Vibrant",     value: "scheme-vibrant"     },
                    { label: "Expressive",  value: "scheme-expressive"  },
                    { label: "Fruit Salad", value: "scheme-fruit-salad" },
                    { label: "Rainbow",     value: "scheme-rainbow"     },
                    { label: "Neutral",     value: "scheme-neutral"     },
                    { label: "Monochrome",  value: "scheme-monochrome"  },
                    { label: "Content",     value: "scheme-content"     },
                    { label: "Fidelity",    value: "scheme-fidelity"    }
                ]
                onSelectedValue: v => Config.theme.matugen.scheme = v
            }
        }
    }

    ContentSubsection {
        title: "Contrast"

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            SliderRow {
                objectName: "theme-matugenContrast"
                icon: "contrast"
                from: -1.0
                to: 1.0
                stepSize: 0.1
                decimals: 1
                stopIndicators: []
                value: Config.theme.matugen.contrast
                onMoved: v => Config.theme.matugen.contrast = v
            }

            SwitchRow {
                objectName: "theme-matugenDark"
                text: "Dark mode"
                icon: "dark_mode"
                checked: Config.theme.matugen.dark
                onToggled: v => Config.theme.matugen.dark = v
            }
        }
    }
}
