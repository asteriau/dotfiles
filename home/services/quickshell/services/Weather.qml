pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Singleton {
    id: root

    property int subscribers: 0
    function subscribe(): void { root.subscribers += 1 }
    function unsubscribe(): void { root.subscribers = Math.max(0, root.subscribers - 1) }

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

    // Derived visual tokens.
    readonly property string glyph:  _glyph(condition, isNight)


    function _glyph(c: string, n: bool): string {
        if (c === "Clear")        return n ? "bedtime" : "wb_sunny";
        if (c === "Clouds")       return "cloud";
        if (c === "Rain" || c === "Drizzle") return "rainy";
        if (c === "Snow")         return "weather_snowy";
        if (c === "Thunderstorm") return "thunderstorm";
        if (c === "Mist" || c === "Fog" || c === "Haze" || c === "Smoke") return "foggy";
        return "cloud";
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
                    console.warn("Weather parse failed:", e);
                }
            }
        }
    }

    Timer {
        interval: 600000
        running: root.subscribers > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: fetcher.running = true
    }
}
