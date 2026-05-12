import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt.labs.folderlistmodel
import Quickshell.Io
import qs.modules.common

MouseArea {
    id: root

    implicitWidth: 940
    implicitHeight: 580

    signal wallpaperSelected(path: string)
    signal closed()

    property string homeDir: ""
    property string currentDir: ""
    property bool useDarkMode: Config.theme.matugen.dark
    property string searchQuery: ""
    property bool showBreadcrumb: true

    readonly property var imageExts: ["jpg","jpeg","png","webp","bmp","gif","avif","tiff","svg","jxl"]

    function isImage(filename) {
        const ext = filename.split(".").pop().toLowerCase();
        return root.imageExts.indexOf(ext) >= 0;
    }

    function navigateTo(dir) {
        if (!dir || dir.length === 0) dir = "/";
        root.currentDir = dir;
    }

    function navigateUp() {
        if (!root.currentDir || root.currentDir === "/") return;
        const parts = root.currentDir.split("/").filter(p => p.length > 0);
        if (parts.length === 0) return;
        parts.pop();
        root.currentDir = parts.length === 0 ? "/" : "/" + parts.join("/");
    }

    function buildSegments(dir) {
        const out = [{ label: "/", path: "/" }];
        if (!dir || dir === "/") return out;
        const parts = dir.split("/").filter(p => p.length > 0);
        let acc = "";
        for (let i = 0; i < parts.length; i++) {
            acc += "/" + parts[i];
            out.push({ label: parts[i], path: acc });
        }
        return out;
    }

    readonly property var pathSegments: buildSegments(root.currentDir)

    property var visibleEntries: []

    function rebuildVisible() {
        const out = [];
        const q = root.searchQuery.toLowerCase();
        for (let i = 0; i < folderModel.count; i++) {
            const name = folderModel.get(i, "fileName");
            if (q.length > 0 && name.toLowerCase().indexOf(q) === -1) continue;
            out.push({
                fileName: name,
                filePath: folderModel.get(i, "filePath"),
                fileIsDir: folderModel.isFolder(i)
            });
        }
        root.visibleEntries = out;
    }

    function selectWallpaper(filePath) {
        if (!filePath || filePath.length === 0) return;
        Config.theme.matugen.dark = root.useDarkMode;
        root.wallpaperSelected(filePath);
    }

    onSearchQueryChanged: rebuildVisible()

    acceptedButtons: Qt.BackButton | Qt.ForwardButton
    onPressed: event => {
        if (event.button === Qt.BackButton) {
            root.navigateUp();
            event.accepted = true;
        }
    }

    focus: true
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            root.closed();
            event.accepted = true;
        } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_L) {
            root.showBreadcrumb = false;
            addressBar.focusEditor();
            event.accepted = true;
        } else if ((event.modifiers & Qt.AltModifier) && event.key === Qt.Key_Up) {
            root.navigateUp();
            event.accepted = true;
        } else if (event.key === Qt.Key_Slash) {
            toolbar.focusSearch();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            if (root.searchQuery.length > 0)
                toolbar.setSearchText(root.searchQuery.substring(0, root.searchQuery.length - 1));
            event.accepted = true;
        } else if (event.text && event.text.length > 0
                   && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
            toolbar.setSearchText(root.searchQuery + event.text);
            toolbar.focusSearch();
            event.accepted = true;
        }
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
        onCountChanged: root.rebuildVisible()
        onStatusChanged: if (status === FolderListModel.Ready) root.rebuildVisible()
    }

    RectangularShadow {
        anchors.fill: card
        radius: card.radius
        blur: 24
        offset: Qt.vector2d(0, Appearance.shadow.verticalOffset)
        spread: 1
        color: Appearance.colors.windowShadow
        cached: true
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Appearance.layout.radiusXxl
        color: Appearance.colors.surfaceContainerLow
        border.width: 1
        border.color: Appearance.colors.border
        clip: true

        RowLayout {
            anchors.fill: parent
            spacing: -4

            FolderSidebar {
                homeDir: root.homeDir
                currentDir: root.currentDir
                onNavigate: path => root.navigateTo(path)
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                AddressBar {
                    id: addressBar
                    currentDir: root.currentDir
                    pathSegments: root.pathSegments
                    showBreadcrumb: root.showBreadcrumb
                    onNavigateUp: root.navigateUp()
                    onNavigate: path => root.navigateTo(path)
                    onShowBreadcrumbChanged: {
                        root.showBreadcrumb = showBreadcrumb;
                        if (showBreadcrumb) root.forceActiveFocus();
                    }
                }

                Item {
                    id: gridRegion
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: Appearance.layout.gapSm

                    WallpaperGrid {
                        anchors.fill: parent
                        entries: root.visibleEntries
                        currentDir: root.currentDir
                        searchQuery: root.searchQuery
                        selectedWallpaperPath: Config.theme.matugen.wallpaper
                        bottomPadding: toolbar.height + Appearance.layout.gapXl
                        onNavigateFolder: path => root.navigateTo(path)
                        onWallpaperSelected: path => root.selectWallpaper(path)
                    }

                    GridToolbar {
                        id: toolbar
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: Appearance.layout.gapMd
                        searchQuery: root.searchQuery
                        useDarkMode: root.useDarkMode
                        entries: root.visibleEntries
                        onSearchEdited: text => root.searchQuery = text
                        onDarkModeToggled: dark => root.useDarkMode = dark
                        onClosed: root.closed()
                        onRandomSelected: path => root.selectWallpaper(path)
                    }
                }
            }
        }
    }
}
