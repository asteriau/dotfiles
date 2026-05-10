pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.utils

Singleton {
    id: root

    readonly property string shellDir: {
        const u = Qt.resolvedUrl("..").toString();
        return u.replace(/^file:\/\//, "").replace(/\/$/, "");
    }

    readonly property bool running: matugenProc.running

    function regenerate(): void {
        const wp = Config.theme.matugen.wallpaper;
        if (!wp || wp.length === 0) return;
        if (Config.theme.mode !== "matugen") return;
        const script =
            'set -e; ' +
            'mkdir -p "$SHELL_DIR/state"; ' +
            'cat > "$SHELL_DIR/state/matugen.toml" <<EOF\n' +
            '[config]\n' +
            '\n' +
            '[templates.quickshell]\n' +
            'input_path  = "$SHELL_DIR/matugen/template.json"\n' +
            'output_path = "$SHELL_DIR/state/colors.json"\n' +
            '\n' +
            '[templates.foot]\n' +
            'input_path  = "$SHELL_DIR/matugen/foot.ini"\n' +
            'output_path = "$SHELL_DIR/state/foot.ini"\n' +
            'EOF\n' +
            'exec matugen image "$WALLPAPER" ' +
                '-m "$MODE" -t "$SCHEME" ' +
                '--contrast "$CONTRAST" ' +
                '--source-color-index 0 ' +
                '--config "$SHELL_DIR/state/matugen.toml"';
        matugenProc.running = false;
        matugenProc.environment = {
            "SHELL_DIR": root.shellDir,
            "WALLPAPER": wp,
            "MODE":      Config.theme.matugen.dark ? "dark" : "light",
            "SCHEME":    Config.theme.matugen.scheme,
            "CONTRAST":  String(Config.theme.matugen.contrast)
        };
        matugenProc.command = ["bash", "-c", script];
        matugenProc.running = true;
    }

    function scheduleRegen(): void {
        if (!Config._loaded) return;
        if (Config.theme.mode !== "matugen") return;
        if (!Config.theme.matugen.wallpaper || Config.theme.matugen.wallpaper.length === 0) return;
        regenDebounce.restart();
    }

    Timer {
        id: regenDebounce
        interval: 350
        repeat: false
        onTriggered: root.regenerate()
    }

    Process {
        id: matugenProc
        running: false
        property bool _started: false
        onRunningChanged: {
            if (running) {
                _started = true;
            } else if (_started) {
                _started = false;
                Theme.reload();
                Quickshell.execDetached(["pkill", "-SIGUSR1", "foot"]);
            }
        }
        stderr: StdioCollector {
            id: matugenStderr
            onStreamFinished: {
                if (matugenStderr.text && matugenStderr.text.trim().length > 0)
                    console.warn("matugen:", matugenStderr.text.trim());
            }
        }
    }

    Connections {
        target: Config
        function onThemeMatugenWallpaperChanged() { root.scheduleRegen(); }
        function onThemeMatugenSchemeChanged()    { root.scheduleRegen(); }
        function onThemeMatugenDarkChanged()      { root.scheduleRegen(); }
        function onThemeMatugenContrastChanged()  { root.scheduleRegen(); }
        function onThemeModeChanged()             { root.scheduleRegen(); }
    }
}
