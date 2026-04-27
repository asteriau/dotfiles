// Weather widget. Set OWM key once:
//   mkdir -p ~/.config/quickshell/secrets
//   printf '%s' 'YOUR_OWM_KEY' > ~/.config/quickshell/secrets/openweathermap.key
//   chmod 600 ~/.config/quickshell/secrets/openweathermap.key

import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.components.shape
import qs.components.text
import qs.sidebar.weather.scene
import qs.utils
import qs.utils.state

Item {
    id: root
    Layout.fillWidth: true
    clip: true

    readonly property int cornerRadius: Config.layout.weatherRadius
    readonly property bool night: WeatherState.isNight
    readonly property bool ready: WeatherState.ready

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.cornerRadius
        }
    }

    // Sky backdrop
    SkyGradient {
        id: sky
        topColor: WeatherState.skyTop
        botColor: WeatherState.skyBot
        opacity: 0.55
        Behavior on opacity { NumberAnimation { duration: M3Easing.durationLong1 } }
    }

    // Animated condition scene wrapped in parallax host
    ParallaxHost {
        id: parallaxHost
        anchors.fill: parent

        Loader {
            id: sceneLoader
            anchors.fill: parent
            source: root.ready ? WeatherState.scene : ""
            opacity: status === Loader.Ready ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: M3Easing.durationLong1
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: M3Easing.emphasizedDecel
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
            GradientStop { position: 1; color: Colors.scrim }
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

            StyledText {
                text: Config.weather.city
                color: Colors.foreground
                opacity: 0.9
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

            StyledText {
                visible: root.ready
                text: Math.round(WeatherState.temp) + "°"
                color: Colors.foreground
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

            StyledText {
                visible: root.ready
                text: {
                    const d = WeatherState.description;
                    return d.length > 0 ? d.charAt(0).toUpperCase() + d.slice(1) : "";
                }
                color: Colors.m3onSurfaceVariant
                font.pixelSize: Config.typography.smallie
                font.weight: Font.Medium
                Layout.topMargin: -4
            }

            StyledText {
                visible: root.ready
                text: "H: " + Math.round(WeatherState.tempMax) + "°  L: " + Math.round(WeatherState.tempMin) + "°"
                color: Colors.comment
                font.pixelSize: 11
                Layout.topMargin: 2
            }

            StyledText {
                visible: !root.ready
                text: WeatherState.errorMessage.length > 0 ? WeatherState.errorMessage : "Loading weather…"
                color: Colors.comment
                font.pixelSize: Config.typography.smaller
                font.weight: Font.Medium
                wrapMode: Text.WordWrap
                Layout.maximumWidth: 240
            }
            StyledText {
                visible: !root.ready && WeatherState.errorMessage.indexOf("401") >= 0
                text: "New keys take ~1-2h to activate"
                color: Colors.comment
                font.pixelSize: 10
                opacity: 0.7
            }
        }

        Rectangle {
            visible: root.ready
            Layout.fillWidth: true
            Layout.topMargin: 10
            height: 1
            color: Colors.hoverStrongest
        }

        RowLayout {
            visible: root.ready
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 14

            StyledText {
                text: "Feels " + Math.round(WeatherState.feelsLike) + "°"
                color: Colors.m3onSurfaceVariant
                font.pixelSize: 11
                font.weight: Font.Medium
            }

            RowLayout {
                spacing: 4
                MaterialIcon {
                    text: "humidity_percentage"
                    pixelSize: 14
                    fill: 1
                    weight: 400
                    grade: 0
                    color: Colors.m3onSurfaceVariant
                }
                StyledText {
                    text: WeatherState.humidity + "%"
                    color: Colors.m3onSurfaceVariant
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }

            RowLayout {
                spacing: 4
                MaterialIcon {
                    text: "air"
                    pixelSize: 14
                    fill: 1
                    weight: 400
                    grade: 0
                    color: Colors.m3onSurfaceVariant
                }
                StyledText {
                    text: Math.round(WeatherState.windSpeed) + " m/s"
                    color: Colors.m3onSurfaceVariant
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }

            Item { Layout.fillWidth: true }
        }
    }
}
