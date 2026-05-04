import QtQuick
import Quickshell.Services.Pipewire
import qs.sidebar.controls
import qs.utils
import qs.utils.state

// Single container holding all three sliders (brightness/night-light, volume,
// mic), modeled after ii's QuickSliders.qml. The implicit gap between sliders
// comes from the slider handle being taller than the track, so no explicit
// Column spacing is needed.
Rectangle {
    id: root

    readonly property bool nlActive: NightLightState.active
    property real verticalPadding: 14
    property real horizontalPadding: 12

    implicitHeight: contentItem.implicitHeight + root.verticalPadding * 2
    radius: Config.layout.radiusLg
    color: Colors.colLayer1
    antialiasing: true

    Column {
        id: contentItem
        spacing: 8
        anchors {
            fill: parent
            leftMargin: root.horizontalPadding
            rightMargin: root.horizontalPadding
            topMargin: root.verticalPadding
            bottomMargin: root.verticalPadding
        }

        // Brightness + Night Light combined slider.
        // Top 70 % (0.3 – 1.0): display brightness.
        // Bottom 30 % (0.0 – 0.3): night-light intensity.
        QuickSlider {
            anchors {
                left: parent.left
                right: parent.right
            }
            materialSymbol: "light_mode"
            secondaryMaterialSymbol: "wb_twilight"
            iconLocation: 0.3
            stopIndicatorValues: (root.nlActive && (BrightnessState.brightness ?? 0) > 0)
                ? [0.3 + (BrightnessState.brightness ?? 0) * 0.7]
                : []
            value: {
                if (root.nlActive) {
                    const nlSlider = NightLightState.tempToSlider(NightLightState.temperature);
                    return 0.3 - nlSlider * 0.3;
                }
                return 0.3 + (BrightnessState.brightness ?? 0) * 0.7;
            }
            onMoved: {
                if (value >= 0.3) {
                    BrightnessState.setBrightness((value - 0.3) / 0.7);
                    if (root.nlActive)
                        NightLightState.setTemperature(NightLightState.maxTemp);
                } else {
                    if ((BrightnessState.brightness ?? 0) !== 0)
                        BrightnessState.setBrightness(0);
                    const nlSlider = 1 - value / 0.3;
                    NightLightState.setTemperature(NightLightState.sliderToTemp(nlSlider));
                }
            }
        }

        QuickSlider {
            anchors {
                left: parent.left
                right: parent.right
            }
            materialSymbol: "volume_up"
            value: PipeWireState.defaultSink?.audio?.volume ?? 0
            onMoved: {
                const a = PipeWireState.defaultSink?.audio;
                if (a) a.volume = value;
            }
        }

        QuickSlider {
            anchors {
                left: parent.left
                right: parent.right
            }
            materialSymbol: "mic"
            value: PipeWireState.defaultSource?.audio?.volume ?? 0
            onMoved: {
                const a = PipeWireState.defaultSource?.audio;
                if (a) a.volume = value;
            }
        }
    }
}
