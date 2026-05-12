import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import qs.modules.common.widgets
import qs.modules.settings
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

ContentPage {
    id: page

    readonly property bool isMatugen: Config.theme.mode === "matugen"

    // ── Preset discovery ──────────────────────────────────────────────────
    readonly property string shellDir: {
        const u = Qt.resolvedUrl("../../..").toString();
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

        ContentSubsection {
            title: "Theme source"

            Item {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 6
                implicitHeight: srcSeg.implicitHeight

                SegmentedControl {
                    id: srcSeg
                    objectName: "theme-source"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    currentValue: Config.theme.mode
                    onSelectedValue: v => Config.theme.mode = v
                    options: [
                        { label: "Preset",  icon: "style",    value: "preset"  },
                        { label: "Matugen", icon: "colorize", value: "matugen" }
                    ]
                }
            }
        }
    }

    // ── Wallpaper ─────────────────────────────────────────────────────────
    ContentSection {
        title: "Wallpaper"

        ContentSubsection {
            title: "Wallpaper"

            Item {
                id: previewItem
                objectName: "theme-wallpaper"
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.preferredHeight: 200

                Rectangle {
                    anchors.fill: parent
                    visible: Config.theme.matugen.wallpaper.length === 0
                    radius: Appearance.layout.radiusMd
                    color: Appearance.colors.surfaceContainerHigh
                    border.width: 1
                    border.color: Appearance.colors.border

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "image"
                        pixelSize: 28
                        color: Appearance.colors.comment
                    }
                }

                Image {
                    id: wpPreview
                    anchors.fill: parent
                    visible: Config.theme.matugen.wallpaper.length > 0
                    source: Config.theme.matugen.wallpaper.length > 0 ? "file://" + Config.theme.matugen.wallpaper : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    sourceSize.width: previewItem.width
                    sourceSize.height: previewItem.height
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.motion.duration.medium2
                            easing.type: Easing.OutCubic
                        }
                    }
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: wpPreview.width
                            height: wpPreview.height
                            radius: Appearance.layout.radiusMd
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 8
                Layout.preferredHeight: 40
                radius: Appearance.layout.radiusMd
                color: chooseMa.containsMouse ? Appearance.colors.surfaceContainerHighest : Appearance.colors.surfaceContainerHigh
                Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Appearance.layout.gapSm

                    MaterialIcon {
                        text: "wallpaper"
                        pixelSize: 16
                        color: Appearance.colors.foreground
                    }
                    StyledText {
                        text: "Choose file"
                        color: Appearance.colors.foreground
                        font.pixelSize: Appearance.typography.small
                        font.weight: Font.Medium
                    }
                }

                MouseArea {
                    id: chooseMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: UiState.showWallpaperPicker = true
                }
            }
        }
    }

    // ── Preset picker ─────────────────────────────────────────────────────
    ContentSection {
        visible: !page.isMatugen
        title: "Preset"

        ContentSubsection {
            title: "Choose a preset"

            Item {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 8
                implicitHeight: presetSeg.visible ? presetSeg.implicitHeight : presetEmpty.implicitHeight

                SegmentedControl {
                    id: presetSeg
                    objectName: "theme-presetPicker"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: page.presetOptions.length > 0
                    currentValue: Config.theme.preset
                    options: page.presetOptions
                    onSelectedValue: v => Config.theme.preset = v
                }

                StyledText {
                    id: presetEmpty
                    anchors.left: parent.left
                    anchors.right: parent.right
                    visible: page.presetOptions.length === 0
                    text: "No presets found in " + page.shellDir + "/themes/"
                    color: Appearance.colors.m3onSurfaceVariant
                    font.pixelSize: Appearance.typography.smallie
                    wrapMode: Text.WordWrap
                }
            }
        }

        ContentSubsection {
            title: "Preset name"
            tooltip: "Basename (without .json) of a file in <shellDir>/themes/"

            TextFieldRow {
                objectName: "theme-presetName"
                text: Config.theme.preset
                onEdited: v => Config.theme.preset = v
            }
        }
    }

    // ── Matugen controls ──────────────────────────────────────────────────
    ContentSection {
        visible: page.isMatugen
        title: "Matugen"

        ContentSubsection {
            title: "Color scheme"

            Item {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 6
                implicitHeight: schemeSeg.implicitHeight

                SegmentedControl {
                    id: schemeSeg
                    objectName: "theme-matugenScheme"
                    anchors.left: parent.left
                    anchors.right: parent.right
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
        }

        ContentSubsection {
            title: "Contrast"

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                SliderRow {
                    objectName: "theme-matugenContrast"
                    icon: "contrast"
                    from: -1.0
                    to: 1.0
                    stepSize: 0.1
                    decimals: 1
                    stopIndicators: []
                    value: Config.theme.matugen.contrast
                    onMoved: v => Config.theme.matugen.contrast = v
                }

                SwitchRow {
                    objectName: "theme-matugenDark"
                    text: "Dark mode"
                    icon: "dark_mode"
                    checked: Config.theme.matugen.dark
                    onToggled: v => Config.theme.matugen.dark = v
                }
            }
        }
    }
}
