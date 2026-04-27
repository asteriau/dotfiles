import QtQuick

// 2-stop vertical sky fade. Consume `WeatherState.skyTop`/`skyBot` in the caller
// so the gradient stays in sync with the current weather condition.
Rectangle {
    id: root
    property color topColor: "transparent"
    property color botColor: "transparent"

    anchors.fill: parent
    gradient: Gradient {
        orientation: Gradient.Vertical
        GradientStop { position: 0; color: root.topColor }
        GradientStop { position: 1; color: root.botColor }
    }
}
