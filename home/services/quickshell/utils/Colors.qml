pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property var currentColorScheme: Application.styleHints.colorScheme

    Connections {
        target: Application.styleHints

        // function onColorSchemeChanged(scheme) {
        //     console.log("Color scheme changed to", scheme);
        //     root.currentColorScheme = scheme;
        // }

        function colorSchemeChange() {
            let scheme = Application.styleHints.colorScheme;
            console.log("Color scheme changed to", scheme);
            root.currentColorScheme = scheme;
        }
    }

    property bool darkMode: currentColorScheme !== Qt.ColorScheme.Light

    readonly property color background: "#151515"
    readonly property color foreground: "#E8E3E3"
    readonly property color elevated: "#222222"
    readonly property color border: "#252525"
    readonly property color mpris: "#8C977D"
    readonly property color foregroundOSD: Qt.hsla(0, 0, 0.95, 0.7)
    readonly property color windowShadow: Qt.rgba(0, 0, 0, 0.2)
    readonly property list<color> monitorColors: ["#8DA3B9", "#D9BC8C", "#8C977D", "#8DA3B9"]

    readonly property color surface: darkMode ? Qt.hsla(0, 0, 0.95, 0.15) : Qt.hsla(0, 0, 0.05, 0.15)
    readonly property color overlay: darkMode ? Qt.hsla(0, 0, 0.95, 0.7) : Qt.hsla(0, 0, 0.05, 0.7)

    readonly property color accent: "#8DA3B9"

    readonly property color buttonEnabled: accent
    readonly property color buttonEnabledHover: Qt.lighter(accent, 0.9)
    readonly property color buttonDisabled: elevated
    readonly property color buttonDisabledHover: Qt.rgba(surface.r, surface.g, surface.b, surface.a + 0.1)
}
