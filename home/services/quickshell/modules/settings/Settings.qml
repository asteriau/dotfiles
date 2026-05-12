import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import qs.modules.common.widgets
import qs.modules.common
import "searchData.js" as SearchData

Window {
    id: settingsWindow
    visible: true
    width: 1100
    height: 760
    minimumWidth: 760
    minimumHeight: 520
    title: "Settings"
    color: Appearance.colors.background

    readonly property string _base: Qt.resolvedUrl(".")
    readonly property real contentPadding: Appearance.layout.pageMargin / 2

    property int currentPage: 0
    property bool navExpanded: width > 900
    readonly property var pages: [
        { name: "Bar",     icon: "dock_to_left", source: _base + "pages/BarPage.qml"     },
        { name: "Theme",   icon: "palette",      source: _base + "pages/ThemePage.qml"   },
        { name: "General", icon: "tune",         source: _base + "pages/GeneralPage.qml" },
        { name: "About",   icon: "info",         source: _base + "pages/AboutPage.qml"   }
    ]

    property string searchQuery: ""
    readonly property bool searchActive: searchQuery.trim().length > 0
    property var searchResults: []
    property string _pendingAnchor: ""

    onSearchQueryChanged: searchResults = SearchData.search(searchQuery)

    function _findByObjectName(node, name) {
        if (!node) return null;
        if (node.objectName === name) return node;
        var kids = node.children || [];
        for (var i = 0; i < kids.length; i++) {
            var r = _findByObjectName(kids[i], name);
            if (r) return r;
        }
        if (node.contentItem && node.contentItem !== node) {
            var r2 = _findByObjectName(node.contentItem, name);
            if (r2) return r2;
        }
        return null;
    }

    function _scrollAndFlash(pageItem, anchorId) {
        if (!pageItem) return;
        var target = settingsWindow._findByObjectName(pageItem, anchorId);
        if (!target) {
            console.warn("Settings search: anchorId not found:", anchorId);
            return;
        }
        var flickable = pageItem;
        while (flickable && !(flickable.contentY !== undefined && flickable.contentHeight !== undefined))
            flickable = flickable.parent;
        if (flickable && flickable.contentY !== undefined) {
            var pos = target.mapToItem(flickable.contentItem, 0, 0);
            var desired = Math.max(0, pos.y - Appearance.layout.gapXl + Appearance.layout.gapSm);
            var max = Math.max(0, flickable.contentHeight - flickable.height);
            flickable.contentY = Math.min(desired, max);
        }
        if (typeof target.flash === "function")
            target.flash();
    }

    function _consumePendingAnchor(pageItem) {
        if (!_pendingAnchor || !pageItem) return;
        _scrollAndFlash(pageItem, _pendingAnchor);
        _pendingAnchor = "";
    }

    function activateResult(entry) {
        if (!entry) return;
        searchQuery = "";
        header.clearSearch();
        currentPage = entry.pageIndex;
        _pendingAnchor = entry.anchorId;
        _consumePendingAnchor(pageLoader.currentItem);
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.DragThreshold
        onTapped: if (header && header.searchField) header.searchField.unfocusInput()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: settingsWindow.contentPadding
        spacing: settingsWindow.contentPadding

        SettingsHeader {
            id: header
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            pageName: settingsWindow.pages[settingsWindow.currentPage].name
            compact: settingsWindow.width < 820
            searchOffsetX: ((settingsWindow.navExpanded
                                ? Appearance.layout.navRailExpanded
                                : Appearance.layout.navRailCollapsed)
                            + settingsWindow.contentPadding) / 2

            onQueryChanged: q => settingsWindow.searchQuery = q
            onEscapePressed: {
                if (settingsWindow.searchQuery.length > 0) {
                    settingsWindow.searchQuery = "";
                    header.clearSearch();
                }
                header.searchField.unfocusInput();
            }
            onArrowDown: searchOverlay.moveSelection(1)
            onArrowUp:   searchOverlay.moveSelection(-1)
            onSubmitted: searchOverlay.activateSelected()
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: settingsWindow.contentPadding

            Item {
                Layout.fillHeight: true
                Layout.margins: 5
                Layout.preferredWidth: settingsWindow.navExpanded
                                        ? Appearance.layout.navRailExpanded
                                        : Appearance.layout.navRailCollapsed

                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: Appearance.motion.duration.spatial
                        easing.type: Easing.OutCubic
                    }
                }

                NavRail {
                    anchors.fill: parent
                    expanded: settingsWindow.navExpanded
                    currentIndex: settingsWindow.currentPage
                    model: settingsWindow.pages
                    onNavigated: idx => settingsWindow.currentPage = idx
                    onToggleExpanded: settingsWindow.navExpanded = !settingsWindow.navExpanded
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.colors.transparent
                radius: Appearance.layout.radiusXxl - settingsWindow.contentPadding
                clip: true

                SettingsPageLoader {
                    id: pageLoader
                    anchors.fill: parent
                    source: settingsWindow.pages[settingsWindow.currentPage].source
                    active: !settingsWindow.searchActive
                    onPageReady: page => settingsWindow._consumePendingAnchor(page)
                }

                SettingsSearchOverlay {
                    id: searchOverlay
                    anchors.fill: parent
                    results: settingsWindow.searchResults
                    query: settingsWindow.searchQuery
                    active: settingsWindow.searchActive
                    onActivated: entry => settingsWindow.activateResult(entry)
                }
            }
        }
    }
}
