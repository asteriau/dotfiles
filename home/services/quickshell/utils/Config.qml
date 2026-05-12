pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string shellDir: {
        const u = Qt.resolvedUrl("..").toString();
        return u.replace(/^file:\/\//, "").replace(/\/$/, "");
    }
    readonly property string configPath: root.shellDir + "/state/config.json"
    readonly property string legacyPath: root.shellDir + "/state/settings.json"
    readonly property int    writeDelay: 250

    readonly property string userName: "Laura"

    readonly property bool _loaded: true

    Timer {
        id: writeTimer
        interval: root.writeDelay
        repeat: false
        onTriggered: configFile.writeAdapter()
    }

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        onFileChanged: configFile.reload()
        onAdapterUpdated: writeTimer.restart()
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                legacyMover.running = true;
                configFile.writeAdapter();
            }
        }

        JsonAdapter {
            id: opts

            property JsonObject bar: JsonObject {
                id: barOpts
                property string position: "left"
                property bool   rounding: true
            }

            property JsonObject workspaces: JsonObject {
                id: workspacesOpts
                property int  shown:             10
                property bool showAppIcons:      true
                property bool alwaysShowNumbers: false
                property bool monochromeIcons:   false
                property bool tintedIcons:       false
            }

            property JsonObject sidebar: JsonObject {
                id: sidebarOpts
                property int width: 420
            }

            property JsonObject osd: JsonObject {
                id: osdOpts
                property int width:     200
                property int timeoutMs: 1000
            }

            property JsonObject notifications: JsonObject {
                id: notificationsOpts
                property bool doNotDisturb: false
            }

            property JsonObject weather: JsonObject {
                id: weatherOpts
                property real   lat:  44.4268
                property real   lon:  26.1025
                property string city: "Bucharest"
            }

            property JsonObject theme: JsonObject {
                id: themeOpts
                property string mode:   "preset"
                property string preset: "default-dark"

                property JsonObject matugen: JsonObject {
                    id: matugenOpts
                    property string scheme:    "scheme-tonal-spot"
                    property bool   dark:      true
                    property real   contrast:  0.0
                    property string wallpaper: ""
                }
            }

            property JsonObject typography: JsonObject {
                id: typographyOpts
                property string family:   "Google Sans Flex"
                property int    iconSize: 14
            }

            property JsonObject screenshot: JsonObject {
                id: screenshotOpts
                property string savePath:      ""
                property string recordingPath: ""

                property JsonObject regionCircle: JsonObject {
                    id: regionCircleOpts
                    property int  strokeWidth: 3
                    property int  padding:     4
                    property bool aimLines:    true
                }
            }
        }
    }

    Process {
        id: legacyMover
        running: false
        command: ["sh", "-c", "[ -f \"$1\" ] && mv \"$1\" \"$1.legacy\" || true", "--", root.legacyPath]
    }

    readonly property QtObject bar: QtObject {
        property alias position: barOpts.position
        property alias rounding: barOpts.rounding

        readonly property bool vertical: position === "left" || position === "right"
        readonly property bool onEnd:    position === "right" || position === "bottom"
    }

    readonly property QtObject sidebar: QtObject {
        property alias width: sidebarOpts.width
    }

    readonly property QtObject workspaces: QtObject {
        property alias shown:             workspacesOpts.shown
        property alias showAppIcons:      workspacesOpts.showAppIcons
        property alias alwaysShowNumbers: workspacesOpts.alwaysShowNumbers
        property alias monochromeIcons:   workspacesOpts.monochromeIcons
        property alias tintedIcons:       workspacesOpts.tintedIcons
    }

    readonly property QtObject osd: QtObject {
        property alias width:     osdOpts.width
        property alias timeoutMs: osdOpts.timeoutMs
    }

    readonly property QtObject notifications: QtObject {
        property alias doNotDisturb: notificationsOpts.doNotDisturb
    }

    readonly property QtObject weather: QtObject {
        property alias lat:  weatherOpts.lat
        property alias lon:  weatherOpts.lon
        property alias city: weatherOpts.city
    }

    readonly property QtObject theme: QtObject {
        property alias mode:   themeOpts.mode
        property alias preset: themeOpts.preset

        readonly property QtObject matugen: QtObject {
            property alias scheme:    matugenOpts.scheme
            property alias dark:      matugenOpts.dark
            property alias contrast:  matugenOpts.contrast
            property alias wallpaper: matugenOpts.wallpaper
        }
    }

    readonly property QtObject typography: QtObject {
        property alias family:   typographyOpts.family
        property alias iconSize: typographyOpts.iconSize
    }

    readonly property QtObject screenshot: QtObject {
        property alias savePath:      screenshotOpts.savePath
        property alias recordingPath: screenshotOpts.recordingPath

        readonly property QtObject regionCircle: QtObject {
            property alias strokeWidth: regionCircleOpts.strokeWidth
            property alias padding:     regionCircleOpts.padding
            property alias aimLines:    regionCircleOpts.aimLines
        }
    }
}
