import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common

ContentSection {
    id: root

    required property var presetOptions
    required property string shellDir

    title: "Preset"

    ContentSubsection {
        title: "Choose a preset"

        Item {
            Layout.fillWidth: true
            Layout.leftMargin: Appearance.layout.gapXl
            Layout.rightMargin: Appearance.layout.gapXl
            Layout.bottomMargin: Appearance.layout.gapMd
            implicitHeight: presetSeg.visible ? presetSeg.implicitHeight : presetEmpty.implicitHeight

            SegmentedControl {
                id: presetSeg
                objectName: "theme-presetPicker"
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.presetOptions.length > 0
                currentValue: Config.theme.preset
                options: root.presetOptions
                onSelectedValue: v => Config.theme.preset = v
            }

            StyledText {
                id: presetEmpty
                anchors.left: parent.left
                anchors.right: parent.right
                visible: root.presetOptions.length === 0
                text: "No presets found in " + root.shellDir + "/themes/"
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

    StyledText {
        Layout.fillWidth: true
        Layout.leftMargin: Appearance.layout.gapXl
        Layout.rightMargin: Appearance.layout.gapXl
        Layout.topMargin: Appearance.layout.gapMd
        Layout.bottomMargin: Appearance.layout.gapMd
        wrapMode: Text.WordWrap
        color: Appearance.colors.m3onSurfaceVariant
        font.pixelSize: Appearance.typography.smallie
        text: "Switching applies live to Quickshell, foot, and Hyprland. " +
              "GTK, QT, and other config-file consumers are included in the " +
              "preset but need a full rebuild (and app restart) to take effect."
    }
}
