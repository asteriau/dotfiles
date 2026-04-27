import QtQuick
import QtQuick.Layouts
import qs.utils

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    property date now: new Date()
    readonly property string longDateLabel: {
        const day = root.now.getDate();
        let suffix = "th";

        if (day % 100 < 11 || day % 100 > 13) {
            if (day % 10 === 1) suffix = "st";
            else if (day % 10 === 2) suffix = "nd";
            else if (day % 10 === 3) suffix = "rd";
        }

        return Qt.formatDateTime(root.now, "dddd, MMMM ") + day + suffix;
    }
    readonly property string weatherGlyph: {
        const c = WeatherState.condition;
        const n = WeatherState.isNight;

        if (c === "Clear") return n ? "bedtime" : "wb_sunny";
        if (c === "Clouds") return "cloud";
        if (c === "Rain" || c === "Drizzle") return "rainy";
        if (c === "Snow") return "weather_snowy";
        if (c === "Thunderstorm") return "thunderstorm";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return "foggy";
        return "cloud";
    }
    readonly property string weatherLabel: {
        const d = WeatherState.description;
        const fallback = WeatherState.condition;
        const label = d.length > 0 ? d : fallback;
        return label.length > 0 ? label.charAt(0).toUpperCase() + label.slice(1) : "Weather";
    }
    readonly property string hiLowLabel: "H " + Math.round(WeatherState.tempMax) + "°  L " + Math.round(WeatherState.tempMin) + "°"

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    component IconBtn: Item {
        id: ib
        property string icon
        signal clicked

        Layout.preferredWidth: 38
        Layout.preferredHeight: 38

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
            antialiasing: true
            Behavior on color {
                ColorAnimation {
                    duration: M3Easing.effectsDuration
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: ib.icon
            font.family: "Material Symbols Rounded"
            font.pixelSize: 18
            color: Colors.m3onSurfaceVariant
            renderType: Text.NativeRendering
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ib.clicked()
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        Text {
            text: Qt.formatDateTime(root.now, "HH:mm")
            color: Colors.foreground
            font.family: Config.fontFamily
            font.pixelSize: 22
            font.weight: Font.Medium
            font.letterSpacing: -0.44
        }

        Text {
            text: root.longDateLabel
            color: Colors.comment
            font.family: Config.fontFamily
            font.pixelSize: 12
        }

        RowLayout {
            visible: WeatherState.ready || WeatherState.errorMessage.length > 0
            spacing: 4

            Text {
                visible: WeatherState.ready
                text: root.weatherLabel
                color: Colors.comment
                font.family: Config.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.maximumWidth: 112
            }

            Text {
                visible: WeatherState.ready
                text: root.hiLowLabel
                color: Colors.comment
                font.family: Config.fontFamily
                font.pixelSize: 12
            }

            RowLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: WeatherState.ready ? Math.round(WeatherState.temp) + "°" : "Weather unavailable"
                    color: Colors.m3onSurfaceVariant
                    font.family: Config.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Medium
                }

                Text {
                    visible: WeatherState.ready
                    Layout.alignment: Qt.AlignVCenter
                    Layout.topMargin: 1
                    text: root.weatherGlyph
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 13
                    font.variableAxes: ({ FILL: 1, wght: 450, opsz: 20, GRAD: 0 })
                    color: Colors.m3onSurfaceVariant
                    renderType: Text.NativeRendering
                }
            }
        }
    }

    Item { Layout.fillWidth: true }

    IconBtn { icon: "edit" }
    IconBtn { icon: "power_settings_new" }
    IconBtn {
        icon: "settings"
        onClicked: Utils.launchSettings()
    }
}
