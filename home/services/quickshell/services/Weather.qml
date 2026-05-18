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

    // Forecast slices derived from the OWM 3h-step list. `hourly` covers the
    // next 24h (8 entries); `daily` aggregates the full 5-day list into
    // per-day min/max with the noon-nearest condition driving the icon.
    property var hourly: []
    property var daily: []

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

    function _entryFromForecast(e): var {
        const code = e.weather?.[0]?.icon ?? "";
        const cond = e.weather?.[0]?.main ?? "";
        return {
            time:      new Date(e.dt * 1000),
            temp:      e.main?.temp ?? 0,
            feelsLike: e.main?.feels_like ?? 0,
            condition: cond,
            iconCode:  code,
            isNight:   code.endsWith("n"),
            glyph:     root._glyph(cond, code.endsWith("n")),
            windSpeed: e.wind?.speed ?? 0,
            humidity:  e.main?.humidity ?? 0
        };
    }

    function _buildHourly(list): var {
        const out = [];
        const n = Math.min(8, list.length);
        for (let i = 0; i < n; i++) out.push(root._entryFromForecast(list[i]));
        return out;
    }

    // Group entries by local day, then for each day reduce to {date, min, max,
    // glyph, condition}. Icon comes from the entry whose hour is closest to
    // noon so days don't pick up nighttime glyphs from the 21:00 / 00:00 slot.
    function _buildDaily(list): var {
        const buckets = new Map();
        for (const e of list) {
            const t = new Date(e.dt * 1000);
            const key = t.getFullYear() + "-" + (t.getMonth() + 1) + "-" + t.getDate();
            if (!buckets.has(key))
                buckets.set(key, { date: new Date(t.getFullYear(), t.getMonth(), t.getDate()), entries: [] });
            buckets.get(key).entries.push(e);
        }
        const days = [];
        for (const b of buckets.values()) {
            let mn = b.entries[0].main.temp_min;
            let mx = b.entries[0].main.temp_max;
            let bestIdx = 0;
            let bestDist = 24;
            for (let i = 0; i < b.entries.length; i++) {
                const e = b.entries[i];
                if (e.main.temp_min < mn) mn = e.main.temp_min;
                if (e.main.temp_max > mx) mx = e.main.temp_max;
                const dist = Math.abs(new Date(e.dt * 1000).getHours() - 12);
                if (dist < bestDist) { bestDist = dist; bestIdx = i; }
            }
            const noon = b.entries[bestIdx];
            const code = noon.weather?.[0]?.icon ?? "";
            const cond = noon.weather?.[0]?.main ?? "";
            days.push({
                date:      b.date,
                tempMin:   mn,
                tempMax:   mx,
                condition: cond,
                glyph:     root._glyph(cond, code.endsWith("n"))
            });
            if (days.length === 5) break;
        }
        return days;
    }


    readonly property string _fetchCmd:
        "KEY=$(cat \"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/secrets/openweathermap.key\" 2>/dev/null); " +
        "[ -n \"$KEY\" ] || exit 0; " +
        "CUR=$(curl -4 -sSL \"https://api.openweathermap.org/data/2.5/weather?lat=" + Config.weather.lat + "&lon=" + Config.weather.lon + "&units=metric&appid=$KEY\"); " +
        "FC=$(curl -4 -sSL \"https://api.openweathermap.org/data/2.5/forecast?lat=" + Config.weather.lat + "&lon=" + Config.weather.lon + "&units=metric&cnt=40&appid=$KEY\"); " +
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
                        root.hourly = root._buildHourly(list);
                        root.daily  = root._buildDaily(list);
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
