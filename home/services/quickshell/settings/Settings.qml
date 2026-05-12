//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import qs.components.controls
import qs.utils
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
        { name: "Bar",     icon: "dock_to_left", source: _base + "pages/Bar.qml"     },
        { name: "Theme",   icon: "palette",      source: _base + "pages/Theme.qml"   },
        { name: "General", icon: "tune",         source: _base + "pages/General.qml" },
        { name: "About",   icon: "info",         source: _base + "pages/About.qml"   }
    ]

    property string searchQuery: ""
    readonly property bool searchActive: searchQuery.trim().length > 0
    property var searchResults: []

    onSearchQueryChanged: {
        searchResults = SearchData.search(searchQuery);
    }

    function _findByObjectName(node, name) {
        if (!node) return null;
        if (node.objectName === name) return node;
        var kids = node.children || [];
        for (var i = 0; i < kids.length; i++) {
            var r = _findByObjectName(kids[i], name);
            if (r) return r;
        }
        // Some nodes expose contentItem children separately (e.g. Flickable contentColumn)
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
        // Walk up to find the Flickable (ContentPage).
        var flickable = pageItem;
        while (flickable && !(flickable.contentY !== undefined && flickable.contentHeight !== undefined)) {
            flickable = flickable.parent;
        }
        if (flickable && flickable.contentY !== undefined) {
            var pos = target.mapToItem(flickable.contentItem, 0, 0);
            var desired = Math.max(0, pos.y - 24);
            var max = Math.max(0, flickable.contentHeight - flickable.height);
            flickable.contentY = Math.min(desired, max);
        }
        if (typeof target.flash === "function") {
            target.flash();
        }
    }

    property string _pendingAnchor: ""

    function _tryScrollFront() {
        if (!_pendingAnchor) return;
        var front = contentCard.frontIsA ? loaderA : loaderB;
        if (front.status === Loader.Ready && front.item) {
            _scrollAndFlash(front.item, _pendingAnchor);
            _pendingAnchor = "";
        }
    }

    function activateResult(entry) {
        if (!entry) return;
        searchQuery = "";
        header.clearSearch();
        currentPage = entry.pageIndex;
        _pendingAnchor = entry.anchorId;
        _tryScrollFront();
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        gesturePolicy: TapHandler.DragThreshold
        onTapped: {
            if (header && header.searchField) {
                header.searchField.unfocusInput();
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: settingsWindow.contentPadding
        spacing: settingsWindow.contentPadding

        // ── Header ────────────────────────────────────────────────────────
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
            onArrowDown: resultsView.moveSelection(1)
            onArrowUp:   resultsView.moveSelection(-1)
            onSubmitted: resultsView.activateSelected()
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: settingsWindow.contentPadding

            // Nav rail
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

            // Content card
            Rectangle {
                id: contentCard
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Appearance.colors.transparent
                radius: 24 - settingsWindow.contentPadding
                clip: true

                // Two loaders crossfade between pages; flip `frontIsA` on each change.
                property bool frontIsA: true
                readonly property string currentSource:
                    settingsWindow.pages[settingsWindow.currentPage].source

                onCurrentSourceChanged: {
                    if (!loaderA.item && !loaderB.item) return;
                    const incoming = frontIsA ? loaderB : loaderA;
                    incoming.source = currentSource;
                    frontIsA = !frontIsA;
                }

                onFrontIsAChanged: settingsWindow._tryScrollFront()

                // ── Page loaders (hidden when searching) ──────────────────
                Loader {
                    id: loaderA
                    anchors.fill: parent
                    asynchronous: true
                    source: contentCard.currentSource
                    readonly property bool targetVisible: !settingsWindow.searchActive && contentCard.frontIsA
                    opacity: targetVisible ? 1 : 0
                    visible: opacity > 0
                    onStatusChanged: if (status === Loader.Ready) settingsWindow._tryScrollFront()
                    transform: Translate {
                        y: loaderA.targetVisible ? 0 : 14
                        Behavior on y {
                            NumberAnimation {
                                duration: Appearance.motion.duration.spatial
                                easing.bezierCurve: Appearance.motion.easing.emphasized
                                easing.type: Easing.BezierSpline
                            }
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.motion.duration.spatial
                            easing.bezierCurve: Appearance.motion.easing.emphasized
                            easing.type: Easing.BezierSpline
                        }
                    }
                }

                Loader {
                    id: loaderB
                    anchors.fill: parent
                    asynchronous: true
                    readonly property bool targetVisible: !settingsWindow.searchActive && !contentCard.frontIsA
                    opacity: targetVisible ? 1 : 0
                    visible: opacity > 0
                    onStatusChanged: if (status === Loader.Ready) settingsWindow._tryScrollFront()
                    transform: Translate {
                        y: loaderB.targetVisible ? 0 : 14
                        Behavior on y {
                            NumberAnimation {
                                duration: Appearance.motion.duration.spatial
                                easing.bezierCurve: Appearance.motion.easing.emphasized
                                easing.type: Easing.BezierSpline
                            }
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.motion.duration.spatial
                            easing.bezierCurve: Appearance.motion.easing.emphasized
                            easing.type: Easing.BezierSpline
                        }
                    }
                }

                // ── Search results overlay ─────────────────────────────────
                SearchResultsView {
                    id: resultsView
                    anchors.fill: parent
                    results: settingsWindow.searchResults
                    query: settingsWindow.searchQuery
                    opacity: settingsWindow.searchActive ? 1 : 0
                    visible: opacity > 0
                    transform: Translate {
                        y: settingsWindow.searchActive ? 0 : 14
                        Behavior on y {
                            NumberAnimation {
                                duration: Appearance.motion.duration.spatial
                                easing.bezierCurve: Appearance.motion.easing.emphasized
                                easing.type: Easing.BezierSpline
                            }
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.motion.duration.spatial
                            easing.bezierCurve: Appearance.motion.easing.emphasized
                            easing.type: Easing.BezierSpline
                        }
                    }
                    onActivated: entry => settingsWindow.activateResult(entry)
                }
            }
        }
    }
}
