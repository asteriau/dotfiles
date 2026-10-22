pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtPositioning

import qs.modules.common

Singleton {
    id: root
    // 10 minute
    readonly property int fetchInterval: Config.options.bar.weather.fetchInterval * 60 * 1000
    readonly property string city: Config.options.bar.weather.city
    readonly property bool useUSCS: Config.options.bar.weather.useUSCS
    property bool gpsActive: Config.options.bar.weather.enableGPS

    onUseUSCSChanged: {
        root.getData();
    }
    onCityChanged: {
        root.getData();
    }

    property var location: ({
        valid: false,
        lat: 0,
        lon: 0
    })

    property var data: ({
        uv: 0,
        humidity: 0,
        sunrise: 0,
        sunset: 0,
        windDir: 0,
        wCode: 0,
        city: 0,
        wind: 0,
        precip: 0,
        visib: 0,
        press: 0,
        temp: 0,
        tempFeelsLike: 0,
        lastRefresh: 0,
        icon: "cloud",
        hi: "--°",
        lo: "--°",
        windDeg: 0,
        dayProgress: 0,
        rangeProgress: 0,
        night: false,
        daylightLeft: "--",
        updated: "--:--",
        hourly: [],
    })

    function refineData(data) {
        let temp = {};
        temp.uv = data?.current?.uvIndex || 0;
        temp.humidity = (data?.current?.humidity || 0) + "%";
        temp.sunrise = data?.astronomy?.sunrise || "0.0";
        temp.sunset = data?.astronomy?.sunset || "0.0";
        temp.windDir = data?.current?.winddir16Point || "N";
        temp.wCode = data?.current?.weatherCode || "113";
        temp.city = data?.location?.areaName[0]?.value || "City";
        temp.desc = data?.current?.weatherDesc?.[0]?.value || "";
        temp.temp = "";
        temp.tempFeelsLike = "";
        if (root.useUSCS) {
            temp.wind = (data?.current?.windspeedMiles || 0) + " mph";
            temp.precip = (data?.current?.precipInches || 0) + " in";
            temp.visib = (data?.current?.visibilityMiles || 0) + " m";
            temp.press = (data?.current?.pressureInches || 0) + " psi";
            temp.temp += (data?.current?.temp_F || 0);
            temp.tempFeelsLike += (data?.current?.FeelsLikeF || 0);
            temp.temp += "°F";
            temp.tempFeelsLike += "°F";
        } else {
            temp.wind = (data?.current?.windspeedKmph || 0) + " km/h";
            temp.precip = (data?.current?.precipMM || 0) + " mm";
            temp.visib = (data?.current?.visibility || 0) + " km";
            temp.press = (data?.current?.pressure || 0) + " hPa";
            temp.temp += (data?.current?.temp_C || 0);
            temp.tempFeelsLike += (data?.current?.FeelsLikeC || 0);
            temp.temp += "°C";
            temp.tempFeelsLike += "°C";
        }
        temp.lastRefresh = DateTime.time + " • " + DateTime.date;
        temp.updated = DateTime.time;

        // Popup extras: today's range, wind heading, daylight progress, 3-hourly outlook
        const us = root.useUSCS;
        const deg = v => Math.round(+v || 0) + "°";
        const today = data?.days?.[0] || {};
        temp.hi = deg(us ? today.maxtempF : today.maxtempC);
        temp.lo = deg(us ? today.mintempF : today.mintempC);
        temp.windDeg = +(data?.current?.winddirDegree || 0);
        const now = new Date();
        const nowM = now.getHours() * 60 + now.getMinutes();
        const rise = parse12h(temp.sunrise), set = parse12h(temp.sunset);
        temp.sunrise = rise != null ? hhmm(rise) : "--:--";
        temp.sunset = set != null ? hhmm(set) : "--:--";
        const night = m => rise != null && set != null && (m < rise || m > set);
        // by day: sunrise→sunset; by night: sunset→sunrise (wrapping midnight)
        temp.dayProgress = rise == null || set == null ? 0
            : night(nowM) ? ((nowM - set + 1440) % 1440) / ((rise - set + 1440) % 1440)
            : (nowM - rise) / (set - rise);
        const cur = +(us ? data?.current?.temp_F : data?.current?.temp_C) || 0;
        const lo = +(us ? today.mintempF : today.mintempC), hi = +(us ? today.maxtempF : today.maxtempC);
        temp.rangeProgress = hi > lo ? Math.min(1, Math.max(0, (cur - lo) / (hi - lo))) : 0;
        temp.night = night(nowM);
        const dur = m => (m >= 60 ? Math.floor(m / 60) + "h " : "") + (m % 60) + "m";
        temp.daylightLeft = rise == null || set == null ? "--" : dur(temp.night ? (rise + 1440 - nowM) % 1440 : set - nowM);
        const icon = (code, m) => {
            const i = Icons.getWeatherIcon(code) ?? "cloud";
            if (!night(m)) return i;
            return i === "clear_day" ? "clear_night" : i === "partly_cloudy_day" ? "partly_cloudy_night" : i;
        };
        temp.icon = icon(temp.wCode, nowM);
        const slots = [];
        (data?.days || []).forEach(d => (d.hourly || []).forEach(h => {
            const hr = Math.round(+h.time / 100);
            const t = new Date(d.date + "T00:00:00");
            t.setHours(hr);
            if (t > now) slots.push({ hr, h });
        }));
        temp.hourly = [{ label: Translation.tr("Now"), icon: temp.icon, temp: deg(us ? data?.current?.temp_F : data?.current?.temp_C), now: true }]
            .concat(slots.slice(0, 5).map(s => ({ label: hhmm(s.hr * 60), icon: icon(s.h.weatherCode, s.hr * 60), temp: deg(us ? s.h.tempF : s.h.tempC), now: false })));
        root.data = temp;
    }

    function parse12h(s) {
        const m = /(\d+):(\d+)\s*(AM|PM)/i.exec(s || "");
        if (!m) return null;
        return (+m[1] % 12 + (/pm/i.test(m[3]) ? 12 : 0)) * 60 + +m[2];
    }

    function hhmm(mins) {
        return String(Math.floor(mins / 60)).padStart(2, "0") + ":" + String(mins % 60).padStart(2, "0");
    }

    function getData() {
        let command = "curl -s wttr.in";

        if (root.gpsActive && root.location.valid) {
            command += `/${root.location.lat},${root.location.long}`;
        } else {
            command += `/${formatCityName(root.city)}`;
        }

        // format as json
        command += "?format=j1";
        command += " | ";
        // only take the current weather, location, asytronmy data
        command += "jq '{current: .current_condition[0], location: .nearest_area[0], astronomy: .weather[0].astronomy[0], days: .weather[0:2]}'";
        fetcher.command[2] = command;
        fetcher.running = true;
    }

    function formatCityName(cityName) {
        return cityName.trim().split(/\s+/).join('+');
    }

    Component.onCompleted: {
        if (!root.gpsActive) return;
        console.info("[WeatherService] Starting the GPS service.");
        positionSource.start();
    }

    Process {
        id: fetcher
        command: ["bash", "-c", ""]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.length === 0)
                    return;
                try {
                    const parsedData = JSON.parse(text);
                    root.refineData(parsedData);
                    // console.info(`[ data: ${JSON.stringify(parsedData)}`);
                } catch (e) {
                    console.error(`[WeatherService] ${e.message}`);
                }
            }
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: root.fetchInterval

        onPositionChanged: {
            // update the location if the given location is valid
            // if it fails getting the location, use the last valid location
            if (position.latitudeValid && position.longitudeValid) {
                root.location.lat = position.coordinate.latitude;
                root.location.long = position.coordinate.longitude;
                root.location.valid = true;
                // console.info(`📍 Location: ${position.coordinate.latitude}, ${position.coordinate.longitude}`);
                root.getData();
                // if can't get initialized with valid location deactivate the GPS
            } else {
                root.gpsActive = root.location.valid ? true : false;
                console.error("[WeatherService] Failed to get the GPS location.");
            }
        }

        onValidityChanged: {
            if (!positionSource.valid) {
                positionSource.stop();
                root.location.valid = false;
                root.gpsActive = false;
                Quickshell.execDetached(["notify-send", Translation.tr("Weather Service"), Translation.tr("Cannot find a GPS service. Using the fallback method instead."), "-a", "Shell"]);
                console.error("[WeatherService] Could not aquire a valid backend plugin.");
            }
        }
    }

    Timer { // Always poll: GPS only refines the location and may never deliver a fix
        running: true
        repeat: true
        interval: root.fetchInterval
        triggeredOnStart: true
        onTriggered: root.getData()
    }
}
