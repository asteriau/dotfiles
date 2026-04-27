pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.utils

Singleton {
    id: root

    property real temp: 0
    property real feelsLike: 0
    property real tempMin: 0
    property real tempMax: 0
    property string condition: ""
    property string description: ""
    property string iconCode: ""
    property int humidity: 0
    property real windSpeed: 0
    property int cloudiness: 0
    property date sunrise: new Date(0)
    property date sunset: new Date(0)
    property date lastUpdated: new Date(0)
    property bool ready: false
    property string errorMessage: ""

    readonly property bool isNight: iconCode.endsWith("n")

    // Derived visual tokens. Callers bind to these instead of repeating the
    // condition/night switch in every widget.
    readonly property url    scene:  _sceneUrl(condition, isNight)
    readonly property string glyph:  _glyph(condition, isNight)
    readonly property color  skyTop: _skyTop(condition, isNight)
    readonly property color  skyBot: _skyBot(condition, isNight)

    function _sceneFile(c: string, n: bool): string {
        if (c === "Clear")        return n ? "NightClearScene.qml" : "SunnyScene.qml";
        if (c === "Clouds")       return "CloudsScene.qml";
        if (c === "Rain" || c === "Drizzle") return "RainScene.qml";
        if (c === "Snow")         return "SnowScene.qml";
        if (c === "Thunderstorm") return "ThunderScene.qml";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return "FogScene.qml";
        return "CloudsScene.qml";
    }

    function _sceneUrl(c: string, n: bool): url {
        return Qt.resolvedUrl("../sidebar/weather/" + _sceneFile(c, n));
    }

    function _glyph(c: string, n: bool): string {
        if (c === "Clear")        return n ? "bedtime" : "wb_sunny";
        if (c === "Clouds")       return "cloud";
        if (c === "Rain" || c === "Drizzle") return "rainy";
        if (c === "Snow")         return "weather_snowy";
        if (c === "Thunderstorm") return "thunderstorm";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return "foggy";
        return "cloud";
    }

    function _skyTop(c: string, n: bool): color {
        if (c === "Clear")        return n ? "#0F1D33" : "#7DB9E8";
        if (c === "Clouds")       return n ? "#252B36" : "#5A6672";
        if (c === "Rain" || c === "Drizzle") return n ? "#1F2A38" : "#39485B";
        if (c === "Snow")         return n ? "#3E4A5C" : "#A7B4C4";
        if (c === "Thunderstorm") return "#1A1E26";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return n ? "#2C313A" : "#7A8590";
        return "#3A434F";
    }

    function _skyBot(c: string, n: bool): color {
        if (c === "Clear")        return n ? "#1C2A44" : "#C2E3F7";
        if (c === "Clouds")       return n ? "#3A4250" : "#A2ADB9";
        if (c === "Rain" || c === "Drizzle") return n ? "#2C3A4C" : "#6A7A8F";
        if (c === "Snow")         return n ? "#5A6577" : "#DCE4EE";
        if (c === "Thunderstorm") return "#3A3F4A";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return n ? "#444B58" : "#B5BDC6";
        return "#5A6470";
    }

    readonly property string _fetchCmd:
        "KEY=$(cat \"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/secrets/openweathermap.key\" 2>/dev/null); " +
        "[ -n \"$KEY\" ] || exit 0; " +
        "CUR=$(curl -4 -sSL \"https://api.openweathermap.org/data/2.5/weather?lat=" + Config.weather.lat + "&lon=" + Config.weather.lon + "&units=metric&appid=$KEY\"); " +
        "FC=$(curl -4 -sSL \"https://api.openweathermap.org/data/2.5/forecast?lat=" + Config.weather.lat + "&lon=" + Config.weather.lon + "&units=metric&cnt=8&appid=$KEY\"); " +
        "printf '%s\\n---\\n%s' \"$CUR\" \"$FC\""

    Process {
        id: fetcher
        running: false
        command: ["bash", "-c", root._fetchCmd]
        stdout: StdioCollector {
            id: collector
            onStreamFinished: {
                const raw = collector.text.trim();
                if (raw.length === 0) {
                    root.errorMessage = "No API key set";
                    return;
                }
                const parts = raw.split("\n---\n");
                try {
                    const cur = JSON.parse(parts[0]);
                    if (cur.cod && Number(cur.cod) !== 200) {
                        root.errorMessage = "OWM " + cur.cod + ": " + (cur.message ?? "error");
                        return;
                    }
                    root.errorMessage = "";
                    root.temp = cur.main?.temp ?? 0;
                    root.feelsLike = cur.main?.feels_like ?? 0;
                    root.humidity = cur.main?.humidity ?? 0;
                    root.tempMin = cur.main?.temp_min ?? 0;
                    root.tempMax = cur.main?.temp_max ?? 0;
                    root.windSpeed = cur.wind?.speed ?? 0;
                    root.cloudiness = cur.clouds?.all ?? 0;
                    root.condition = cur.weather?.[0]?.main ?? "";
                    root.description = cur.weather?.[0]?.description ?? "";
                    root.iconCode = cur.weather?.[0]?.icon ?? "";
                    if (cur.sys?.sunrise)
                        root.sunrise = new Date(cur.sys.sunrise * 1000);
                    if (cur.sys?.sunset)
                        root.sunset = new Date(cur.sys.sunset * 1000);

                    if (parts.length > 1) {
                        const fc = JSON.parse(parts[1]);
                        const list = fc.list ?? [];
                        if (list.length > 0) {
                            let mn = list[0].main.temp_min;
                            let mx = list[0].main.temp_max;
                            for (const e of list) {
                                if (e.main.temp_min < mn) mn = e.main.temp_min;
                                if (e.main.temp_max > mx) mx = e.main.temp_max;
                            }
                            root.tempMin = mn;
                            root.tempMax = mx;
                        }
                    }

                    root.lastUpdated = new Date();
                    root.ready = true;
                } catch (e) {
                    console.warn("WeatherState parse failed:", e);
                }
            }
        }
    }

    Timer {
        interval: 600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: fetcher.running = true
    }
}
