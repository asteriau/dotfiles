import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import qs.components.content
import qs.components.controls
import qs.components.text
import qs.settings
import qs.utils

ContentPage {
    id: page

    readonly property bool isMatugen: Config.theme.mode === "matugen"

    // ── Preset discovery ──────────────────────────────────────────────────
    readonly property string shellDir: {
        const u = Qt.resolvedUrl("../..").toString();
        return u.replace(/^file:\/\//, "").replace(/\/$/, "");
    }

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

    // ─────────────────────────────────────────────────────────────────────
    ContentSection {
        title: "Source"
        icon: "palette"

        ContentSubsection {
            title: "Theme source"

            SegmentedControl {
                currentValue: Config.theme.mode
                onSelectedValue: v => Config.theme.mode = v
                options: [
                    { label: "Preset",  icon: "style",    value: "preset"  },
                    { label: "Matugen", icon: "colorize", value: "matugen" }
                ]
            }
        }
    }

    // ── Wallpaper ─────────────────────────────────────────────────────────
    ContentSection {
        title: "Wallpaper"
        icon: "wallpaper"

        ContentSubsection {
            title: "Wallpaper"

            // Preview
            Item {
                id: previewItem
                Layout.fillWidth: true
                Layout.preferredHeight: 200

                Rectangle {
                    anchors.fill: parent
                    visible: Config.theme.matugen.wallpaper.length === 0
                    radius: Config.layout.radiusMd
                    color: Colors.surfaceContainerHigh
                    border.width: 1
                    border.color: Colors.border

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "image"
                        pixelSize: 28
                        color: Colors.comment
                    }
                }

                Image {
                    id: wpPreview
                    anchors.fill: parent
                    visible: Config.theme.matugen.wallpaper.length > 0
                    source: visible ? "file://" + Config.theme.matugen.wallpaper : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
                    sourceSize.width: previewItem.width
                    sourceSize.height: previewItem.height
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: wpPreview.width
                            height: wpPreview.height
                            radius: Config.layout.radiusMd
                        }
                    }
                }
            }

            // Choose file button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: Config.layout.radiusMd
                color: chooseMa.containsMouse ? Colors.surfaceContainerHighest : Colors.surfaceContainerHigh
                Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Config.layout.gapSm

                    MaterialIcon {
                        text: "wallpaper"
                        pixelSize: 16
                        color: Colors.foreground
                    }
                    StyledText {
                        text: "Choose file"
                        color: Colors.foreground
                        font.pixelSize: Config.typography.small
                        font.weight: Font.Medium
                    }
                }

                MouseArea {
                    id: chooseMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Config.showWallpaperPicker = true
                }
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
                onSelectedValue: v => Config.theme.matugen.scheme = v
            }
        }

        SwitchRow {
            text: "Dark mode"
            icon: "dark_mode"
            checked: Config.theme.matugen.dark
            onToggled: v => Config.theme.matugen.dark = v
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
                onMoved: v => Config.theme.matugen.contrast = v
            }
        }
    }
}
