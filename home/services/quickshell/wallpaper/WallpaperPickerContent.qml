import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell.Io
import qs.utils
import qs.components.controls
import qs.components.text

Item {
    id: root

    implicitWidth: 940
    implicitHeight: 580

    signal wallpaperSelected(path: string)
    signal closed()

    property string homeDir: ""
    property string currentDir: ""

    readonly property var imageExts: ["jpg","jpeg","png","webp","bmp","gif","avif","tiff","svg","jxl"]

    function isImage(filename) {
        const ext = filename.split(".").pop().toLowerCase();
        return root.imageExts.indexOf(ext) >= 0;
    }

    function navigateTo(dir) {
        root.currentDir = dir;
    }

    function navigateUp() {
        if (!root.currentDir || root.currentDir === "/") return;
        const parts = root.currentDir.split("/").filter(p => p.length > 0);
        if (parts.length === 0) return;
        parts.pop();
        root.currentDir = parts.length === 0 ? "/" : "/" + parts.join("/");
    }

    Process {
        id: homeDirProc
        command: ["sh", "-c", "printf '%s' \"$HOME\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.homeDir = text;
                if (root.currentDir.length === 0) {
                    const wp = Config.theme.matugen.wallpaper;
                    if (wp.length > 0) {
                        const parts = wp.split("/").filter(p => p.length > 0);
                        parts.pop();
                        root.currentDir = parts.length === 0 ? "/" : "/" + parts.join("/");
                    } else {
                        root.currentDir = root.homeDir + "/Pictures/Wallpapers";
                    }
                }
            }
        }
    }

    FolderListModel {
        id: folderModel
        folder: root.currentDir.length > 0 ? ("file://" + root.currentDir) : ""
        showDirs: true
        showDirsFirst: true
        showHidden: false
        nameFilters: ["*.jpg","*.jpeg","*.png","*.webp","*.bmp","*.gif","*.avif","*.tiff","*.svg","*.jxl"]
        sortField: FolderListModel.Name
    }

    // Card
    Rectangle {
        anchors.fill: parent
        radius: Config.layout.radiusXxl
        color: Colors.surfaceContainerLow
        border.width: 1
        border.color: Colors.border
        clip: true

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // Sidebar
            Rectangle {
                Layout.preferredWidth: 156
                Layout.fillHeight: true
                color: Colors.surfaceContainer
                radius: Config.layout.radiusXxl

                // Square off the right side
                Rectangle {
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    width: parent.radius
                    color: parent.color
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Config.layout.gapMd
                    spacing: Config.layout.gapXs

                    StyledText {
                        text: "Wallpaper"
                        font.pixelSize: Config.typography.normal
                        font.weight: Font.Medium
                        color: Colors.foreground
                        Layout.topMargin: Config.layout.gapSm
                        Layout.leftMargin: 6
                        Layout.bottomMargin: Config.layout.gapXs
                    }

                    Repeater {
                        model: [
                            { icon: "home",     label: "Home",       path: root.homeDir },
                            { icon: "image",    label: "Pictures",   path: root.homeDir + "/Pictures" },
                            { icon: "wallpaper",label: "Wallpapers", path: root.homeDir + "/Pictures/Wallpapers" },
                            { icon: "download", label: "Downloads",  path: root.homeDir + "/Downloads" },
                            { icon: "movie",    label: "Videos",     path: root.homeDir + "/Videos" },
                        ]
                        delegate: RippleButton {
                            id: quickDirBtn
                            required property var modelData
                            Layout.fillWidth: true
                            buttonRadius: Config.layout.radiusMd
                            implicitHeight: 36
                            enabled: root.homeDir.length > 0
                            toggled: root.currentDir === quickDirBtn.modelData.path
                            colBackgroundToggled: Colors.surfaceContainerHigh
                            colBackgroundToggledHover: Colors.surfaceContainerHighest
                            colRippleToggled: Colors.hoverStrong
                            onClicked: root.navigateTo(quickDirBtn.modelData.path)

                            contentItem: RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: Config.layout.gapSm

                                MaterialIcon {
                                    text: quickDirBtn.modelData.icon
                                    pixelSize: Config.typography.larger
                                    color: quickDirBtn.toggled ? Colors.accent : Colors.foreground
                                }
                                StyledText {
                                    text: quickDirBtn.modelData.label
                                    font.pixelSize: Config.typography.small
                                    color: quickDirBtn.toggled ? Colors.accent : Colors.foreground
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            // Main area
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Address bar
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Config.layout.gapMd
                    Layout.leftMargin: Config.layout.gapMd
                    Layout.rightMargin: Config.layout.gapMd
                    spacing: Config.layout.gapSm

                    RippleButton {
                        buttonRadius: Config.layout.radiusMd
                        implicitWidth: 30
                        implicitHeight: 30
                        enabled: root.currentDir.length > 0 && root.currentDir !== "/"
                        onClicked: root.navigateUp()
                        contentItem: MaterialIcon {
                            anchors.centerIn: parent
                            text: "arrow_upward"
                            pixelSize: 16
                            color: Colors.foreground
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: Config.layout.radiusMd
                        color: Colors.surfaceContainer
                        border.width: pathInput.activeFocus ? 1 : 0
                        border.color: Colors.accent
                        Behavior on border.color { ColorAnimation { duration: M3Easing.effectsDuration } }

                        TextInput {
                            id: pathInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            text: root.currentDir
                            color: Colors.foreground
                            selectionColor: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.4)
                            font.pixelSize: Config.typography.smallie
                            font.family: Config.typography.family
                            clip: true

                            // Keep in sync with currentDir, but don't clobber user edits while focused
                            Binding on text {
                                when: !pathInput.activeFocus
                                value: root.currentDir
                            }

                            Keys.onReturnPressed: {
                                root.navigateTo(text);
                                grid.forceActiveFocus();
                            }
                            Keys.onEscapePressed: {
                                text = root.currentDir;
                                grid.forceActiveFocus();
                            }
                        }
                    }

                    RippleButton {
                        buttonRadius: Config.layout.radiusMd
                        implicitWidth: 30
                        implicitHeight: 30
                        onClicked: root.closed()
                        contentItem: MaterialIcon {
                            anchors.centerIn: parent
                            text: "close"
                            pixelSize: 16
                            color: Colors.foreground
                        }
                    }
                }

                // Empty state
                Item {
                    visible: folderModel.count === 0 && root.currentDir.length > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Config.layout.gapMd

                        MaterialIcon {
                            text: "folder_open"
                            pixelSize: 48
                            color: Colors.comment
                            Layout.alignment: Qt.AlignHCenter
                        }
                        StyledText {
                            text: "No images found"
                            font.pixelSize: Config.typography.small
                            color: Colors.comment
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }

                // Grid
                GridView {
                    id: grid
                    visible: folderModel.count > 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: Config.layout.gapMd

                    clip: true
                    focus: true

                    readonly property int cols: 4
                    cellWidth: Math.floor(width / cols)
                    cellHeight: Math.floor(cellWidth * 3 / 4)

                    model: folderModel

                    Keys.onLeftPressed:  if (currentIndex > 0) currentIndex--
                    Keys.onRightPressed: if (currentIndex < count - 1) currentIndex++
                    Keys.onUpPressed:    if (currentIndex >= cols) currentIndex -= cols
                    Keys.onDownPressed:  if (currentIndex + cols < count) currentIndex += cols
                    Keys.onReturnPressed: activateCurrent()
                    Keys.onEscapePressed: root.closed()

                    function activateCurrent() {
                        const path = folderModel.get(currentIndex, "filePath");
                        const isDir = folderModel.isFolder(currentIndex);
                        if (isDir) root.navigateTo(path);
                        else if (path) root.wallpaperSelected(path);
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 4
                            radius: 2
                            color: Colors.border
                        }
                    }

                    delegate: Item {
                        id: cell
                        required property string fileName
                        required property string filePath
                        required property bool fileIsDir
                        required property int index

                        width: grid.cellWidth
                        height: grid.cellHeight

                        readonly property bool isCurrent:   grid.currentIndex === index
                        readonly property bool isWallpaper: filePath === Config.theme.matugen.wallpaper
                        readonly property bool showThumb:   !fileIsDir && root.isImage(fileName)

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            radius: Config.layout.radiusMd
                            color: cell.isWallpaper   ? Colors.primaryContainer
                                 : cell.isCurrent      ? Colors.surfaceContainerHigh
                                 : "transparent"
                            Behavior on color {
                                ColorAnimation { duration: M3Easing.effectsDuration }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 4
                                spacing: 3

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Image {
                                        visible: cell.showThumb
                                        anchors.fill: parent
                                        source: cell.showThumb ? ("file://" + cell.filePath) : ""
                                        fillMode: Image.PreserveAspectCrop
                                        sourceSize.width: 240
                                        sourceSize.height: 180
                                        asynchronous: true
                                        cache: true
                                        clip: true
                                    }

                                    MaterialIcon {
                                        visible: cell.fileIsDir
                                        anchors.centerIn: parent
                                        text: "folder"
                                        pixelSize: 28
                                        color: Colors.accent
                                    }

                                    MaterialIcon {
                                        visible: !cell.showThumb && !cell.fileIsDir
                                        anchors.centerIn: parent
                                        text: "image"
                                        pixelSize: 28
                                        color: Colors.comment
                                    }
                                }

                                StyledText {
                                    Layout.fillWidth: true
                                    text: cell.fileName
                                    font.pixelSize: Config.typography.smaller
                                    color: cell.isWallpaper ? Colors.m3onPrimaryContainer : Colors.foreground
                                    elide: Text.ElideRight
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered:  grid.currentIndex = cell.index
                                onClicked: {
                                    grid.currentIndex = cell.index;
                                    if (cell.fileIsDir) {
                                        root.navigateTo(cell.filePath);
                                    } else if (cell.showThumb) {
                                        root.wallpaperSelected(cell.filePath);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
