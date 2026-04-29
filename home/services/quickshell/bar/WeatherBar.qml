import QtQuick
import qs.components.effects
import qs.components.text
import qs.utils
import qs.utils.state

HoverTooltip {
    id: root

    visible: WeatherState.ready

    text: [
        `${Math.round(WeatherState.temp)}° (feels ${Math.round(WeatherState.feelsLike)}°)`,
        `Humidity: ${WeatherState.humidity}%`,
        `Wind: ${WeatherState.windSpeed.toFixed(1)} m/s`,
        WeatherState.description !== "" ? WeatherState.description : ""
    ].filter(s => s !== "").join("\n")

    implicitWidth:  row.implicitWidth
    implicitHeight: row.implicitHeight

    Row {
        id: row
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter

        MaterialIcon {
            text: WeatherState.glyph
            pixelSize: Config.typography.normal
            color: Colors.foreground
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Math.round(WeatherState.temp) + "°"
            font.family: Config.fontFamily
            font.pixelSize: Config.typography.small
            color: Colors.foreground
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
