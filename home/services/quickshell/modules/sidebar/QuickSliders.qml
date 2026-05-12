import QtQuick
import Quickshell.Services.Pipewire
import qs.modules.sidebar.controls
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

Rectangle {
    id: root

    readonly property bool nlActive: NightLight.active
    property real verticalPadding: 14
    property real horizontalPadding: 12

    implicitHeight: contentItem.implicitHeight + root.verticalPadding * 2
    radius: Appearance.layout.radiusLg
    color: Appearance.colors.colLayer1
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
            stopIndicatorValues: (root.nlActive && (Brightness.brightness ?? 0) > 0)
                ? [0.3 + (Brightness.brightness ?? 0) * 0.7]
                : []
            value: {
                if (root.nlActive) {
                    const nlSlider = NightLight.tempToSlider(NightLight.temperature);
                    return 0.3 - nlSlider * 0.3;
                }
                return 0.3 + (Brightness.brightness ?? 0) * 0.7;
            }
            onMoved: {
                if (value >= 0.3) {
                    Brightness.setBrightness((value - 0.3) / 0.7);
                    if (root.nlActive)
                        NightLight.setTemperature(NightLight.maxTemp);
                } else {
                    if ((Brightness.brightness ?? 0) !== 0)
                        Brightness.setBrightness(0);
                    const nlSlider = 1 - value / 0.3;
                    NightLight.setTemperature(NightLight.sliderToTemp(nlSlider));
                }
            }
        }

        QuickSlider {
            anchors {
                left: parent.left
                right: parent.right
            }
            materialSymbol: "volume_up"
            value: Audio.defaultSink?.audio?.volume ?? 0
            onMoved: {
                const a = Audio.defaultSink?.audio;
                if (a) a.volume = value;
            }
            onRightClicked: UiState.sidebarMenu = "volume"
        }

        QuickSlider {
            anchors {
                left: parent.left
                right: parent.right
            }
            materialSymbol: "mic"
            value: Audio.defaultSource?.audio?.volume ?? 0
            onMoved: {
                const a = Audio.defaultSource?.audio;
                if (a) a.volume = value;
            }
        }
    }
}
