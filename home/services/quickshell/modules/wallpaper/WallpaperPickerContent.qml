import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import Qt.labs.folderlistmodel
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.modules.common.widgets

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
        if (grid.currentIndex >= out.length) grid.currentIndex = 0;
    }

    onSearchQueryChanged: rebuildVisible()
    onCurrentDirChanged: pathInput.text = currentDir

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
            pathInput.forceActiveFocus();
            pathInput.selectAll();
            event.accepted = true;
        } else if ((event.modifiers & Qt.AltModifier) && event.key === Qt.Key_Up) {
            root.navigateUp();
            event.accepted = true;
        } else if (event.key === Qt.Key_Slash) {
            searchField.forceActiveFocus();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            if (root.searchQuery.length > 0) {
                root.searchQuery = root.searchQuery.substring(0, root.searchQuery.length - 1);
                searchField.text = root.searchQuery;
                searchField.cursorPosition = searchField.text.length;
            }
            event.accepted = true;
        } else if (event.text && event.text.length > 0
                   && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
            searchField.text += event.text;
            searchField.cursorPosition = searchField.text.length;
            searchField.forceActiveFocus();
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

    // Drop shadow
    RectangularShadow {
        anchors.fill: card
        radius: card.radius
        blur: 24
        offset: Qt.vector2d(0, Appearance.shadow.verticalOffset)
        spread: 1
        color: Appearance.colors.windowShadow
        cached: true
    }

    // Card
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

            // Sidebar
            Rectangle {
                Layout.fillHeight: true
                Layout.margins: 4
                Layout.preferredWidth: 148
                color: Appearance.colors.surfaceContainer
                radius: card.radius - Layout.margins

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    StyledText {
                        Layout.margins: 12
                        text: "Pick a wallpaper"
                        font.pixelSize: Appearance.typography.normal
                        font.weight: Font.Medium
                        color: Appearance.colors.foreground
                    }

                    ListView {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Layout.margins: 4
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
                            id: quickDirBtn
                            required property var modelData
                            anchors.left: parent?.left
                            anchors.right: parent?.right
                            implicitHeight: 38
                            buttonRadius: height / 2
                            enabled: root.homeDir.length > 0
                            toggled: root.currentDir === quickDirBtn.modelData.path
                            colBackgroundToggled: Appearance.colors.secondaryContainer
                            colBackgroundToggledHover: Qt.lighter(Appearance.colors.secondaryContainer, 1.06)
                            colRippleToggled: Appearance.colors.hoverStrong
                            onClicked: root.navigateTo(quickDirBtn.modelData.path)

                            contentItem: RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Appearance.layout.gapLg
                                anchors.rightMargin: Appearance.layout.gapLg
                                spacing: Appearance.layout.gapSm

                                MaterialIcon {
                                    text: quickDirBtn.modelData.icon
                                    pixelSize: Appearance.typography.larger
                                    fill: quickDirBtn.toggled ? 1 : 0
                                    color: quickDirBtn.toggled
                                        ? Appearance.colors.m3onSecondaryContainer
                                        : Appearance.colors.m3onSurfaceVariant
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    text: quickDirBtn.modelData.label
                                    horizontalAlignment: Text.AlignLeft
                                    font.pixelSize: Appearance.typography.small
                                    color: quickDirBtn.toggled
                                        ? Appearance.colors.m3onSecondaryContainer
                                        : Appearance.colors.m3onSurfaceVariant
                                }
                            }
                        }
                    }
                }
            }

            // Main area
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // Address bar
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 4
                    Layout.preferredHeight: 44
                    radius: height / 2
                    color: Appearance.colors.surfaceContainer

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: Appearance.layout.gapMd

                        RippleButton {
                            Layout.alignment: Qt.AlignVCenter
                            implicitWidth: 32
                            implicitHeight: 32
                            buttonRadius: height / 2
                            enabled: root.currentDir.length > 0 && root.currentDir !== "/"
                            onClicked: root.navigateUp()
                            contentItem: MaterialIcon {
                                text: "drive_folder_upload"
                                pixelSize: Appearance.typography.larger
                                color: Appearance.colors.foreground
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            // Editable path mode
                            Rectangle {
                                visible: !root.showBreadcrumb
                                anchors.fill: parent
                                radius: height / 2
                                color: Appearance.colors.surfaceContainerLow

                                TextInput {
                                    id: pathInput
                                    anchors.fill: parent
                                    anchors.leftMargin: Appearance.layout.gapLg
                                    anchors.rightMargin: Appearance.layout.gapLg
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: root.currentDir
                                    color: Appearance.colors.foreground
                                    selectionColor: Qt.rgba(Appearance.colors.accent.r, Appearance.colors.accent.g, Appearance.colors.accent.b, 0.4)
                                    font.pixelSize: Appearance.typography.smallie
                                    font.family: Config.typography.family
                                    clip: true
                                    selectByMouse: true

                                    Keys.onReturnPressed: {
                                        root.navigateTo(text);
                                        root.showBreadcrumb = true;
                                        root.forceActiveFocus();
                                    }
                                    Keys.onEscapePressed: {
                                        text = root.currentDir;
                                        root.showBreadcrumb = true;
                                        root.forceActiveFocus();
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        acceptedButtons: Qt.NoButton
                                        cursorShape: Qt.IBeamCursor
                                    }
                                }
                            }

                            // Breadcrumb mode
                            ListView {
                                id: breadcrumb
                                visible: root.showBreadcrumb
                                anchors.fill: parent
                                orientation: ListView.Horizontal
                                clip: true
                                spacing: Appearance.layout.gapXs
                                interactive: false
                                model: root.pathSegments

                                onCountChanged: positionViewAtEnd()
                                Component.onCompleted: positionViewAtEnd()

                                delegate: Rectangle {
                                    id: seg
                                    required property var modelData
                                    required property int index

                                    readonly property bool leftmost:  index === 0
                                    readonly property bool rightmost: index === root.pathSegments.length - 1
                                    readonly property bool isCurrent: rightmost
                                    readonly property int  bigR:   height / 2
                                    readonly property int  smallR: 4

                                    width: Math.max(28, segText.implicitWidth + 20)
                                    height: breadcrumb.height

                                    color: isCurrent
                                        ? Appearance.colors.secondaryContainer
                                        : (segMa.containsMouse ? Appearance.colors.colLayer2Hover : "transparent")
                                    Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

                                    topLeftRadius:     leftmost  ? bigR : (isCurrent ? bigR : smallR)
                                    bottomLeftRadius:  leftmost  ? bigR : (isCurrent ? bigR : smallR)
                                    topRightRadius:    rightmost ? bigR : (isCurrent ? bigR : smallR)
                                    bottomRightRadius: rightmost ? bigR : (isCurrent ? bigR : smallR)

                                    StyledText {
                                        id: segText
                                        anchors.centerIn: parent
                                        text: seg.modelData.label
                                        font.pixelSize: Appearance.typography.smaller
                                        color: seg.isCurrent
                                            ? Appearance.colors.m3onSecondaryContainer
                                            : Appearance.colors.m3onSurfaceVariant
                                    }

                                    MouseArea {
                                        id: segMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.navigateTo(seg.modelData.path)
                                    }
                                }
                            }
                        }

                        RippleButton {
                            id: editBtn
                            Layout.alignment: Qt.AlignVCenter
                            implicitWidth: 32
                            implicitHeight: 32
                            buttonRadius: height / 2
                            toggled: !root.showBreadcrumb
                            colBackgroundToggled: Appearance.colors.accent
                            colRippleToggled: Appearance.colors.accentHover
                            onClicked: {
                                root.showBreadcrumb = !root.showBreadcrumb;
                                if (!root.showBreadcrumb) {
                                    pathInput.forceActiveFocus();
                                    pathInput.selectAll();
                                } else {
                                    root.forceActiveFocus();
                                }
                            }
                            contentItem: MaterialIcon {
                                text: "edit"
                                pixelSize: Appearance.typography.larger
                                color: editBtn.toggled ? Appearance.colors.m3onPrimary : Appearance.colors.foreground
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                // Grid + empty state
                Item {
                    id: gridRegion
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 4

                    // Empty state
                    ColumnLayout {
                        visible: root.visibleEntries.length === 0 && root.currentDir.length > 0
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
                        visible: root.visibleEntries.length > 0
                        anchors.fill: parent

                        clip: true
                        focus: true
                        keyNavigationWraps: true
                        boundsBehavior: Flickable.StopAtBounds
                        bottomMargin: bottomBar.height + 16

                        readonly property int cols: 4
                        cellWidth: Math.floor(width / cols)
                        cellHeight: Math.floor(cellWidth * 3 / 4)

                        model: root.visibleEntries
                        onModelChanged: currentIndex = 0

                        Keys.onLeftPressed:  if (currentIndex > 0) currentIndex--
                        Keys.onRightPressed: if (currentIndex < count - 1) currentIndex++
                        Keys.onUpPressed:    if (currentIndex >= cols) currentIndex -= cols
                        Keys.onDownPressed:  if (currentIndex + cols < count) currentIndex += cols
                        Keys.onReturnPressed: activateCurrent()
                        Keys.onEnterPressed:  activateCurrent()

                        function activateCurrent() {
                            const e = root.visibleEntries[currentIndex];
                            if (!e) return;
                            if (e.fileIsDir) root.navigateTo(e.filePath);
                            else root.selectWallpaper(e.filePath);
                        }

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
                            readonly property bool isWallpaper:  modelData.filePath === Config.theme.matugen.wallpaper
                            readonly property bool showThumb:    !modelData.fileIsDir && root.isImage(modelData.fileName)

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                radius: Appearance.layout.radiusMd
                                color: cell.isCurrent
                                    ? Appearance.colors.accent
                                    : cell.isWallpaper
                                        ? Appearance.colors.secondaryContainer
                                        : Qt.rgba(Appearance.colors.primaryContainer.r, Appearance.colors.primaryContainer.g, Appearance.colors.primaryContainer.b, 0.35)
                                Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }

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
                                        if (cell.modelData.fileIsDir) root.navigateTo(cell.modelData.filePath);
                                        else if (cell.showThumb) root.selectWallpaper(cell.modelData.filePath);
                                    }
                                }
                            }
                        }
                    }

                    // Bottom toolbar
                    RowLayout {
                        id: bottomBar
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottomMargin: Appearance.layout.gapMd
                        spacing: 6

                        Rectangle {
                            id: toolbarPill
                            Layout.preferredHeight: 44
                            implicitWidth: toolbarRow.implicitWidth + 12
                            radius: height / 2
                            color: Appearance.colors.surfaceContainer
                            border.width: 1
                            border.color: Appearance.colors.cardBorder

                            RowLayout {
                                id: toolbarRow
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                spacing: Appearance.layout.gapSm

                                RippleButton {
                                    Layout.alignment: Qt.AlignVCenter
                                    implicitWidth: 36
                                    implicitHeight: 36
                                    buttonRadius: height / 2
                                    enabled: root.visibleEntries.length > 0
                                    onClicked: {
                                        const images = root.visibleEntries.filter(e => !e.fileIsDir && root.isImage(e.fileName));
                                        if (images.length === 0) return;
                                        const pick = images[Math.floor(Math.random() * images.length)];
                                        root.selectWallpaper(pick.filePath);
                                    }
                                    contentItem: MaterialIcon {
                                        text: "shuffle"
                                        pixelSize: Appearance.typography.larger
                                        color: Appearance.colors.foreground
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                RippleButton {
                                    id: darkBtn
                                    Layout.alignment: Qt.AlignVCenter
                                    implicitWidth: 36
                                    implicitHeight: 36
                                    buttonRadius: height / 2
                                    onClicked: root.useDarkMode = !root.useDarkMode
                                    contentItem: MaterialIcon {
                                        text: root.useDarkMode ? "dark_mode" : "light_mode"
                                        pixelSize: Appearance.typography.larger
                                        color: Appearance.colors.foreground
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                TextField {
                                    id: searchField
                                    Layout.preferredWidth: 200
                                    Layout.alignment: Qt.AlignVCenter
                                    placeholderText: activeFocus ? "Search wallpapers" : "Hit \"/\" to search"
                                    color: Appearance.colors.foreground
                                    placeholderTextColor: Appearance.colors.m3onSurfaceInactive
                                    selectionColor: Qt.rgba(Appearance.colors.accent.r, Appearance.colors.accent.g, Appearance.colors.accent.b, 0.4)
                                    selectedTextColor: Appearance.colors.foreground
                                    font.family: Config.typography.family
                                    font.pixelSize: Appearance.typography.small
                                    leftPadding: 10
                                    rightPadding: 10
                                    topPadding: 6
                                    bottomPadding: 6
                                    selectByMouse: true
                                    background: Rectangle { color: "transparent" }

                                    onTextChanged: root.searchQuery = text
                                    Keys.onEscapePressed: { text = ""; root.forceActiveFocus(); }
                                    Keys.onDownPressed:   { grid.forceActiveFocus(); event.accepted = true; }
                                }
                            }
                        }

                        RippleButton {
                            id: closeFab
                            Layout.alignment: Qt.AlignVCenter
                            Layout.preferredWidth: 44
                            Layout.preferredHeight: 44
                            buttonRadius: height / 2
                            colBackground: Appearance.colors.accent
                            colBackgroundHover: Appearance.colors.accentHover
                            colRipple: Appearance.colors.accentPressed
                            onClicked: root.closed()
                            contentItem: MaterialIcon {
                                text: "close"
                                pixelSize: Appearance.typography.larger
                                color: Appearance.colors.m3onPrimary
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }

    function selectWallpaper(filePath) {
        if (!filePath || filePath.length === 0) return;
        Config.theme.matugen.dark = root.useDarkMode;
        root.wallpaperSelected(filePath);
    }
}
