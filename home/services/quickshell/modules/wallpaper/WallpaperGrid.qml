import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.modules.common
import qs.modules.common.widgets

Item {
    id: root

    required property var entries
    required property string currentDir
    property string searchQuery: ""
    property string selectedWallpaperPath: ""
    property var imageExts: ["jpg","jpeg","png","webp","bmp","gif","avif","tiff","svg","jxl"]
    property real bottomPadding: 0

    signal navigateFolder(string path)
    signal wallpaperSelected(string path)

    function isImage(filename) {
        const ext = filename.split(".").pop().toLowerCase();
        return root.imageExts.indexOf(ext) >= 0;
    }

    function activateCurrent(): void {
        const e = root.entries[grid.currentIndex];
        if (!e) return;
        if (e.fileIsDir) root.navigateFolder(e.filePath);
        else root.wallpaperSelected(e.filePath);
    }

    onEntriesChanged: {
        if (grid.currentIndex >= entries.length) grid.currentIndex = 0;
    }

    ColumnLayout {
        visible: root.entries.length === 0 && root.currentDir.length > 0
        anchors.centerIn: parent
        spacing: Appearance.layout.gapMd

        MaterialIcon {
            text: root.searchQuery.length > 0 ? "search_off" : "folder_open"
            pixelSize: 48
            color: Appearance.colors.comment
            Layout.alignment: Qt.AlignHCenter
        }
        StyledText {
            text: root.searchQuery.length > 0 ? "No matches" : "No images found"
            font.pixelSize: Appearance.typography.small
            color: Appearance.colors.comment
            Layout.alignment: Qt.AlignHCenter
        }
    }

    GridView {
        id: grid
        visible: root.entries.length > 0
        anchors.fill: parent

        clip: true
        focus: true
        keyNavigationWraps: true
        boundsBehavior: Flickable.StopAtBounds
        bottomMargin: root.bottomPadding

        readonly property int cols: 4
        cellWidth: Math.floor(width / cols)
        cellHeight: Math.floor(cellWidth * 3 / 4)

        model: root.entries
        onModelChanged: currentIndex = 0

        Keys.onLeftPressed:  if (currentIndex > 0) currentIndex--
        Keys.onRightPressed: if (currentIndex < count - 1) currentIndex++
        Keys.onUpPressed:    if (currentIndex >= cols) currentIndex -= cols
        Keys.onDownPressed:  if (currentIndex + cols < count) currentIndex += cols
        Keys.onReturnPressed: root.activateCurrent()
        Keys.onEnterPressed:  root.activateCurrent()

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            contentItem: Rectangle {
                implicitWidth: 4
                radius: 2
                color: Appearance.colors.border
            }
        }

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: grid.width
                height: grid.height
                Rectangle {
                    anchors.fill: parent
                    radius: Appearance.layout.radiusMd
                }
            }
        }

        delegate: Item {
            id: cell
            required property var modelData
            required property int index

            width: grid.cellWidth
            height: grid.cellHeight

            readonly property bool isCurrent:    grid.currentIndex === index || cellMa.containsMouse
            readonly property bool isWallpaper:  modelData.filePath === root.selectedWallpaperPath
            readonly property bool showThumb:    !modelData.fileIsDir && root.isImage(modelData.fileName)

            Rectangle {
                anchors.fill: parent
                anchors.margins: Appearance.layout.gapSm
                radius: Appearance.layout.radiusMd
                color: cell.isCurrent
                    ? Appearance.colors.accent
                    : cell.isWallpaper
                        ? Appearance.colors.secondaryContainer
                        : Qt.rgba(Appearance.colors.primaryContainer.r, Appearance.colors.primaryContainer.g, Appearance.colors.primaryContainer.b, 0.35)
                Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.layout.gapSm
                    spacing: 3

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Image {
                            visible: cell.showThumb
                            anchors.fill: parent
                            source: cell.showThumb ? ("file://" + cell.modelData.filePath) : ""
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 240
                            sourceSize.height: 180
                            asynchronous: true
                            cache: true
                            clip: true

                            layer.enabled: true
                            layer.effect: OpacityMask {
                                maskSource: Item {
                                    width: cell.width
                                    height: cell.height
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: Appearance.layout.radiusSm
                                    }
                                }
                            }
                        }

                        MaterialIcon {
                            visible: cell.modelData.fileIsDir
                            anchors.centerIn: parent
                            text: "folder"
                            pixelSize: 32
                            fill: 1
                            color: cell.isCurrent ? Appearance.colors.m3onPrimary : Appearance.colors.accent
                        }

                        MaterialIcon {
                            visible: !cell.showThumb && !cell.modelData.fileIsDir
                            anchors.centerIn: parent
                            text: "image"
                            pixelSize: 28
                            color: Appearance.colors.comment
                        }
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: cell.modelData.fileName
                        font.pixelSize: Appearance.typography.smaller
                        color: cell.isCurrent
                            ? Appearance.colors.m3onPrimary
                            : cell.isWallpaper
                                ? Appearance.colors.m3onSecondaryContainer
                                : Appearance.colors.foreground
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MouseArea {
                    id: cellMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: grid.currentIndex = cell.index
                    onClicked: {
                        grid.currentIndex = cell.index;
                        if (cell.modelData.fileIsDir) root.navigateFolder(cell.modelData.filePath);
                        else if (cell.showThumb) root.wallpaperSelected(cell.modelData.filePath);
                    }
                }
            }
        }
    }
}
