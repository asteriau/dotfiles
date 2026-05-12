import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

Rectangle {
    id: root

    required property string homeDir
    required property string currentDir

    signal navigate(string path)

    Layout.fillHeight: true
    Layout.margins: Appearance.layout.gapSm
    Layout.preferredWidth: 148
    color: Appearance.colors.surfaceContainer
    radius: Appearance.layout.radiusXxl - Layout.margins

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        StyledText {
            Layout.margins: Appearance.layout.gapLg
            text: "Pick a wallpaper"
            font.pixelSize: Appearance.typography.normal
            font.weight: Font.Medium
            color: Appearance.colors.foreground
        }

        ListView {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: Appearance.layout.gapSm
            clip: true
            interactive: false
            spacing: Appearance.layout.gapXs

            model: [
                { icon: "home",      label: "Home",       path: root.homeDir },
                { icon: "image",     label: "Pictures",   path: root.homeDir + "/Pictures" },
                { icon: "wallpaper", label: "Wallpapers", path: root.homeDir + "/Pictures/Wallpapers" },
                { icon: "download",  label: "Downloads",  path: root.homeDir + "/Downloads" },
                { icon: "movie",     label: "Videos",     path: root.homeDir + "/Videos" },
            ]

            delegate: RippleButton {
                id: btn
                required property var modelData
                anchors.left: parent?.left
                anchors.right: parent?.right
                implicitHeight: 38
                buttonRadius: height / 2
                enabled: root.homeDir.length > 0
                toggled: root.currentDir === btn.modelData.path
                colBackgroundToggled: Appearance.colors.secondaryContainer
                colBackgroundToggledHover: Qt.lighter(Appearance.colors.secondaryContainer, 1.06)
                colRippleToggled: Appearance.colors.hoverStrong
                onClicked: root.navigate(btn.modelData.path)

                contentItem: RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Appearance.layout.gapLg
                    anchors.rightMargin: Appearance.layout.gapLg
                    spacing: Appearance.layout.gapSm

                    MaterialIcon {
                        text: btn.modelData.icon
                        pixelSize: Appearance.typography.larger
                        fill: btn.toggled ? 1 : 0
                        color: btn.toggled
                            ? Appearance.colors.m3onSecondaryContainer
                            : Appearance.colors.m3onSurfaceVariant
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: btn.modelData.label
                        horizontalAlignment: Text.AlignLeft
                        font.pixelSize: Appearance.typography.small
                        color: btn.toggled
                            ? Appearance.colors.m3onSecondaryContainer
                            : Appearance.colors.m3onSurfaceVariant
                    }
                }
            }
        }
    }
}
