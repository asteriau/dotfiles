import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.modules.common.widgets
import qs.modules.common

ContentSection {
    id: root

    title: "Wallpaper"

    ContentSubsection {
        title: "Wallpaper"

        Item {
            id: previewItem
            objectName: "theme-wallpaper"
            Layout.fillWidth: true
            Layout.leftMargin: Appearance.layout.gapXl
            Layout.rightMargin: Appearance.layout.gapXl
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
            Layout.leftMargin: Appearance.layout.gapXl
            Layout.rightMargin: Appearance.layout.gapXl
            Layout.bottomMargin: Appearance.layout.gapMd
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
