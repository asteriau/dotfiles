import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import qs.components.content
import qs.components.controls
import qs.components.text
import qs.settings
import qs.utils

ContentPage {
    id: page

    readonly property bool isMatugen: Config.theme.mode === "matugen"

    // Shell source dir resolved at runtime (page is in settings/pages/).
    readonly property string shellDir: {
        const u = Qt.resolvedUrl("../..").toString();
        return u.replace(/^file:\/\//, "").replace(/\/$/, "");
    }

    // ── Preset discovery ──────────────────────────────────────────────────
    FolderListModel {
        id: presetsModel
        folder: "file://" + page.shellDir + "/themes"
        nameFilters: ["*.json"]
        showDirs: false
        sortField: FolderListModel.Name
    }

    property var presetOptions: []

    function _prettify(s: string): string {
        return s.split("-").map(w => w.length === 0 ? w : (w.charAt(0).toUpperCase() + w.slice(1))).join(" ");
    }

    function rebuildPresetOptions(): void {
        const out = [];
        for (let i = 0; i < presetsModel.count; i++) {
            const name = presetsModel.get(i, "fileBaseName");
            if (name && name.length > 0) out.push({ label: page._prettify(name), value: name });
        }
        page.presetOptions = out;
    }

    Connections {
        target: presetsModel
        function onCountChanged() { page.rebuildPresetOptions(); }
    }
    Component.onCompleted: rebuildPresetOptions()

    // ── Matugen regeneration ──────────────────────────────────────────────
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

    function regenerateMatugen(): void {
        const wp = Config.theme.matugen.wallpaper;
        if (!wp || wp.length === 0) return;
        // Generate a matugen config with absolute paths resolved from the
        // shell source dir (which is not necessarily ~/.config/quickshell),
        // then shell out to matugen against that generated config. This
        // sidesteps the ~-expansion / install-location problem entirely.
        const script =
            'set -e; ' +
            'mkdir -p "$SHELL_DIR/state"; ' +
            'cat > "$SHELL_DIR/state/matugen.toml" <<EOF\n' +
            '[config]\n' +
            '\n' +
            '[templates.quickshell]\n' +
            'input_path  = "$SHELL_DIR/matugen/template.json"\n' +
            'output_path = "$SHELL_DIR/state/colors.json"\n' +
            'EOF\n' +
            'exec matugen image "$WALLPAPER" ' +
                '-m "$MODE" -t "$SCHEME" ' +
                '--contrast "$CONTRAST" ' +
                '--source-color-index 0 ' +
                '--config "$SHELL_DIR/state/matugen.toml"';
        matugenProc.running = false;
        matugenProc.environment = {
            "SHELL_DIR": page.shellDir,
            "WALLPAPER": wp,
            "MODE":      Config.theme.matugen.dark ? "dark" : "light",
            "SCHEME":    Config.theme.matugen.scheme,
            "CONTRAST":  String(Config.theme.matugen.contrast)
        };
        matugenProc.command = ["bash", "-c", script];
        matugenProc.running = true;
    }

    Timer {
        id: regenDebounce
        interval: 350
        repeat: false
        onTriggered: page.regenerateMatugen()
    }
    function scheduleRegen(): void { regenDebounce.restart(); }

    FileDialog {
        id: wallpaperDialog
        title: "Pick a wallpaper"
        fileMode: FileDialog.OpenFile
        nameFilters: ["Images (*.jpg *.jpeg *.png *.webp *.gif *.bmp)", "All files (*)"]
        onAccepted: {
            const p = selectedFile.toString().replace(/^file:\/\//, "");
            Config.theme.matugen.wallpaper = p;
            page.scheduleRegen();
        }
    }

    // ─────────────────────────────────────────────────────────────────────
    ContentSection {
        title: "Source"
        icon: "palette"

        ContentSubsection {
            title: "Theme source"

            SegmentedControl {
                currentValue: Config.theme.mode
                onSelectedValue: v => {
                    Config.theme.mode = v;
                    if (v === "matugen" && Config.theme.matugen.wallpaper.length > 0)
                        page.scheduleRegen();
                }
                options: [
                    { label: "Preset",  icon: "style",    value: "preset"  },
                    { label: "Matugen", icon: "colorize", value: "matugen" }
                ]
            }
        }
    }

    // ── Preset picker ─────────────────────────────────────────────────────
    ContentSection {
        visible: !page.isMatugen
        title: "Preset"
        icon: "style"

        ContentSubsection {
            title: "Choose a preset"

            SegmentedControl {
                visible: page.presetOptions.length > 0
                currentValue: Config.theme.preset
                options: page.presetOptions
                onSelectedValue: v => Config.theme.preset = v
            }

            StyledText {
                visible: page.presetOptions.length === 0
                text: "No presets found in " + page.shellDir + "/themes/"
                color: Colors.comment
                font.pixelSize: Config.typography.smallie
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        ContentSubsection {
            title: "Preset name"
            tooltip: "Basename (without .json) of a file in <shellDir>/themes/"

            TextFieldRow {
                text: Config.theme.preset
                onEdited: v => Config.theme.preset = v
            }
        }
    }

    // ── Matugen controls ──────────────────────────────────────────────────
    ContentSection {
        visible: page.isMatugen
        title: "Matugen"
        icon: "colorize"

        ContentSubsection {
            title: "Scheme"

            SegmentedControl {
                currentValue: Config.theme.matugen.scheme
                options: [
                    { label: "Tonal Spot",  value: "scheme-tonal-spot"  },
                    { label: "Vibrant",     value: "scheme-vibrant"     },
                    { label: "Expressive",  value: "scheme-expressive"  },
                    { label: "Fruit Salad", value: "scheme-fruit-salad" },
                    { label: "Rainbow",     value: "scheme-rainbow"     },
                    { label: "Neutral",     value: "scheme-neutral"     },
                    { label: "Monochrome",  value: "scheme-monochrome"  },
                    { label: "Content",     value: "scheme-content"     },
                    { label: "Fidelity",    value: "scheme-fidelity"    }
                ]
                onSelectedValue: v => {
                    Config.theme.matugen.scheme = v;
                    page.scheduleRegen();
                }
            }
        }

        SwitchRow {
            text: "Dark mode"
            icon: "dark_mode"
            checked: Config.theme.matugen.dark
            onToggled: v => {
                Config.theme.matugen.dark = v;
                page.scheduleRegen();
            }
        }

        ContentSubsection {
            title: "Contrast"

            SliderRow {
                icon: "contrast"
                from: -1.0
                to: 1.0
                stepSize: 0.1
                decimals: 1
                value: Config.theme.matugen.contrast
                onMoved: v => {
                    Config.theme.matugen.contrast = v;
                    page.scheduleRegen();
                }
            }
        }

        ContentSubsection {
            title: "Wallpaper"

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TextFieldRow {
                    Layout.fillWidth: true
                    text: Config.theme.matugen.wallpaper
                    onEdited: v => {
                        Config.theme.matugen.wallpaper = v;
                        page.scheduleRegen();
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36
                    radius: Config.layout.radiusMd
                    color: pickMa.containsMouse ? Colors.hoverStrong : Colors.surfaceContainerHigh
                    Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }

                    StyledText {
                        anchors.centerIn: parent
                        text: "Pick\u2026"
                        color: Colors.foreground
                        font.pixelSize: Config.typography.smallie
                        font.weight: Font.Medium
                    }

                    MouseArea {
                        id: pickMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wallpaperDialog.open()
                    }
                }
            }
        }

        ContentSubsection {
            title: "Actions"

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Config.layout.radiusMd
                enabled: Config.theme.matugen.wallpaper.length > 0
                opacity: enabled ? 1.0 : 0.5
                color: regenMa.containsMouse && enabled ? Colors.accentHover : Colors.accent
                Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }

                StyledText {
                    anchors.centerIn: parent
                    text: "Regenerate now"
                    color: Colors.accentText
                    font.pixelSize: Config.typography.small
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: regenMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    onClicked: if (parent.enabled) page.regenerateMatugen()
                }
            }

            StyledText {
                Layout.topMargin: 4
                text: "Requires the `matugen` CLI on PATH. Output is written to " + page.shellDir + "/state/colors.json and reloaded automatically."
                color: Colors.comment
                font.pixelSize: Config.typography.smaller
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }
    }
}
