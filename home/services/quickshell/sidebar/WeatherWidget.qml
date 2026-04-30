// Weather widget. Set OWM key once:
//   mkdir -p ~/.config/quickshell/secrets
//   printf '%s' 'YOUR_OWM_KEY' > ~/.config/quickshell/secrets/openweathermap.key
//   chmod 600 ~/.config/quickshell/secrets/openweathermap.key

import QtQuick
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

    readonly property int cornerRadius: Config.layout.weatherRadius
    readonly property bool night: WeatherState.isNight
    readonly property bool ready: WeatherState.ready

    Rectangle {
        id: cardMask
        anchors.fill: parent
        radius: root.cornerRadius
        color: "white"
        visible: false
        layer.enabled: true
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: root.cornerRadius
        color: Colors.surfaceContainer
        border.width: 1
        border.color: Colors.outlineVariant

        layer.enabled: true
        layer.smooth: true
        layer.effect: OpacityMask {
            maskSource: cardMask
        }

        // Animated scene fills full card
        Item {
            id: sceneStrip
            anchors.fill: parent
            clip: true

            SkyGradient {
                anchors.fill: parent
                topColor: WeatherState.skyTop
                botColor: WeatherState.skyBot
                opacity: 0.9
                Behavior on opacity { NumberAnimation { duration: M3Easing.durationLong1 } }
            }

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

            // City label overlaid on scene
            StyledText {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 16
                text: Config.weather.city
                color: Colors.foreground
                opacity: 0.95
                font.pixelSize: 14
                font.weight: Font.Medium
                style: Text.Raised
                styleColor: Qt.rgba(0, 0, 0, 0.35)
            }
        }

        // Bottom info panel
        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            anchors.bottomMargin: 14
            spacing: 0

            StyledText {
                visible: root.ready
                text: Math.round(WeatherState.temp) + "°"
                color: Colors.foreground
                font.pixelSize: 48
                font.weight: Font.Thin
                font.letterSpacing: -2.0
                Layout.bottomMargin: -4
            }

            StyledText {
                visible: root.ready
                text: {
                    const d = WeatherState.description;
                    return d.length > 0 ? d.charAt(0).toUpperCase() + d.slice(1) : "";
                }
                color: Colors.comment
                font.pixelSize: Config.typography.smallie
                font.weight: Font.Medium
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
                color: Colors.foreground
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

            Rectangle {
                visible: root.ready
                Layout.fillWidth: true
                Layout.topMargin: 10
                height: 1
                color: Colors.outlineVariant
                opacity: 0.5
            }

            RowLayout {
                visible: root.ready
                Layout.fillWidth: true
                Layout.topMargin: 8
                spacing: 14

                StyledText {
                    text: "Feels " + Math.round(WeatherState.feelsLike) + "°"
                    color: Colors.comment
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
                        color: Colors.comment
                    }
                    StyledText {
                        text: WeatherState.humidity + "%"
                        color: Colors.comment
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
                        color: Colors.comment
                    }
                    StyledText {
                        text: Math.round(WeatherState.windSpeed) + " m/s"
                        color: Colors.comment
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
