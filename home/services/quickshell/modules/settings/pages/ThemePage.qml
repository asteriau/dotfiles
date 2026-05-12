import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.settings.pages.theme

ContentPage {
    id: page

    readonly property bool isMatugen: Config.theme.mode === "matugen"

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

    ContentSection {
        title: "Source"

        ContentSubsection {
            title: "Theme source"

            Item {
                Layout.fillWidth: true
                Layout.leftMargin: Appearance.layout.gapXl
                Layout.rightMargin: Appearance.layout.gapXl
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

    WallpaperPreview {}

    PresetSection {
        visible: !page.isMatugen
        presetOptions: page.presetOptions
        shellDir: page.shellDir
    }

    MatugenSection {
        visible: page.isMatugen
    }
}
