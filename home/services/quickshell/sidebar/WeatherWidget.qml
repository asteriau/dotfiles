// Weather widget. Set OWM key once:
//   mkdir -p ~/.config/quickshell/secrets
//   printf '%s' 'YOUR_OWM_KEY' > ~/.config/quickshell/secrets/openweathermap.key
//   chmod 600 ~/.config/quickshell/secrets/openweathermap.key

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.components
import qs.utils
import qs.sidebar.weather

Item {
    id: root
    Layout.fillWidth: true
    clip: true

    readonly property int cornerRadius: 22
    readonly property string cond: WeatherState.condition
    readonly property bool night: WeatherState.isNight
    readonly property bool ready: WeatherState.ready

    function sceneSource(c, n) {
        if (c === "Clear")        return n ? "weather/NightClearScene.qml" : "weather/SunnyScene.qml";
        if (c === "Clouds")       return "weather/CloudsScene.qml";
        if (c === "Rain" || c === "Drizzle") return "weather/RainScene.qml";
        if (c === "Snow")         return "weather/SnowScene.qml";
        if (c === "Thunderstorm") return "weather/ThunderScene.qml";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return "weather/FogScene.qml";
        return "weather/CloudsScene.qml";
    }

    function glyph(c, n) {
        if (c === "Clear")        return n ? "bedtime" : "wb_sunny";
        if (c === "Clouds")       return "cloud";
        if (c === "Rain" || c === "Drizzle") return "rainy";
        if (c === "Snow")         return "weather_snowy";
        if (c === "Thunderstorm") return "thunderstorm";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return "foggy";
        return "cloud";
    }

    function skyTop(c, n) {
        if (c === "Clear")        return n ? "#0F1D33" : "#7DB9E8";
        if (c === "Clouds")       return n ? "#252B36" : "#5A6672";
        if (c === "Rain" || c === "Drizzle") return n ? "#1F2A38" : "#39485B";
        if (c === "Snow")         return n ? "#3E4A5C" : "#A7B4C4";
        if (c === "Thunderstorm") return "#1A1E26";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return n ? "#2C313A" : "#7A8590";
        return "#3A434F";
    }
    function skyBot(c, n) {
        if (c === "Clear")        return n ? "#1C2A44" : "#C2E3F7";
        if (c === "Clouds")       return n ? "#3A4250" : "#A2ADB9";
        if (c === "Rain" || c === "Drizzle") return n ? "#2C3A4C" : "#6A7A8F";
        if (c === "Snow")         return n ? "#5A6577" : "#DCE4EE";
        if (c === "Thunderstorm") return "#3A3F4A";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return n ? "#444B58" : "#B5BDC6";
        return "#5A6470";
    }

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.cornerRadius
        }
    }

    // Sky backdrop
    Rectangle {
        id: sky
        anchors.fill: parent
        opacity: 0.55
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0; color: root.skyTop(root.cond, root.night) }
            GradientStop { position: 1; color: root.skyBot(root.cond, root.night) }
        }
        Behavior on opacity { NumberAnimation { duration: 420 } }
    }

    // Animated condition scene wrapped in parallax host
    ParallaxHost {
        id: parallaxHost
        anchors.fill: parent

        Loader {
            id: sceneLoader
            anchors.fill: parent
            source: root.ready ? root.sceneSource(root.cond, root.night) : ""
            opacity: status === Loader.Ready ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 420
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: [0.05, 0.7, 0.1, 1.0, 1, 1]
                }
            }
            onLoaded: {
                if (item) {
                    if (item.hasOwnProperty("parallaxX"))
                        item.parallaxX = Qt.binding(() => parallaxHost.parallaxX);
                    if (item.hasOwnProperty("parallaxY"))
                        item.parallaxY = Qt.binding(() => parallaxHost.parallaxY);
                    if (item.hasOwnProperty("isNight"))
                        item.isNight = Qt.binding(() => root.night);
                }
            }
        }
    }

    // Subtle bottom shade for text legibility against bright scenes
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height * 0.55
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0; color: "transparent" }
            GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.22) }
        }
    }

    // Foreground content
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: "Bucharest"
                color: Colors.foreground
                opacity: 0.9
                font.family: Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Normal

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.6
                    shadowOpacity: 0.35
                    shadowVerticalOffset: 2
                    shadowColor: "black"
                }
            }
        }

        Item { Layout.fillHeight: true }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                visible: root.ready
                text: Math.round(WeatherState.temp) + "°"
                color: Colors.foreground
                font.family: Config.fontFamily
                font.pixelSize: 56
                font.weight: Font.Thin
                font.letterSpacing: -2.4

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.6
                    shadowOpacity: 0.35
                    shadowVerticalOffset: 2
                    shadowColor: "black"
                }
            }

            Text {
                visible: root.ready
                text: {
                    const d = WeatherState.description;
                    return d.length > 0 ? d.charAt(0).toUpperCase() + d.slice(1) : "";
                }
                color: Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 13
                font.weight: Font.Medium
                Layout.topMargin: -4
            }

            Text {
                visible: root.ready
                text: "H: " + Math.round(WeatherState.tempMax) + "°  L: " + Math.round(WeatherState.tempMin) + "°"
                color: Colors.comment
                font.family: Config.fontFamily
                font.pixelSize: 11
                Layout.topMargin: 2
            }

            Text {
                visible: !root.ready
                text: WeatherState.errorMessage.length > 0 ? WeatherState.errorMessage : "Loading weather…"
                color: Colors.comment
                font.family: Config.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 240
            }
            Text {
                visible: !root.ready && WeatherState.errorMessage.indexOf("401") >= 0
                text: "New keys take ~1-2h to activate"
                color: Colors.comment
                font.family: Config.fontFamily
                font.pixelSize: 10
                opacity: 0.7
            }
        }

        Rectangle {
            visible: root.ready
            Layout.fillWidth: true
            Layout.topMargin: 10
            height: 1
            color: Qt.rgba(1, 1, 1, 0.12)
        }

        RowLayout {
            visible: root.ready
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 14

            Text {
                text: "Feels " + Math.round(WeatherState.feelsLike) + "°"
                color: Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 11
                font.weight: Font.Medium
            }

            RowLayout {
                spacing: 4
                Text {
                    text: "humidity_percentage"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 14
                    font.variableAxes: ({ FILL: 1, wght: 400, opsz: 20, GRAD: 0 })
                    color: Colors.m3onSurfaceVariant
                    renderType: Text.NativeRendering
                }
                Text {
                    text: WeatherState.humidity + "%"
                    color: Colors.m3onSurfaceVariant
                    font.family: Config.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }

            RowLayout {
                spacing: 4
                Text {
                    text: "air"
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 14
                    font.variableAxes: ({ FILL: 1, wght: 400, opsz: 20, GRAD: 0 })
                    color: Colors.m3onSurfaceVariant
                    renderType: Text.NativeRendering
                }
                Text {
                    text: Math.round(WeatherState.windSpeed) + " m/s"
                    color: Colors.m3onSurfaceVariant
                    font.family: Config.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }

            Item { Layout.fillWidth: true }
        }
    }
}
