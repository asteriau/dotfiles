pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common.widgets
import qs.modules.launcher
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    readonly property string query: LauncherSearch.query
    readonly property bool showResults: query !== ""
    readonly property bool queryEmpty: query === ""

    property alias listView: listView
    property alias searchBar: searchBar

    // Mirrored results. While query is non-empty, mirror live. When user
    // empties the query, hold the previous list intact during the fade-out
    // so items can crossfade with the notch shrink instead of vanishing.
    property var displayedResults: LauncherSearch.results.slice(0, 15)
    Connections {
        target: LauncherSearch
        function onResultsChanged() {
            if (LauncherSearch.query !== "") {
                clearTimer.stop();
                root.displayedResults = LauncherSearch.results.slice(0, 15);
            } else {
                clearTimer.restart();
            }
        }
    }
    Timer {
        id: clearTimer
        interval: Appearance.motion.duration.long2
        onTriggered: root.displayedResults = []
    }

    // Target height for parent (Island) to drive notch animation.
    // Computed from intrinsic content sizes — does not depend on actual
    // layout height, so it doesn't oscillate while ColumnLayout reflows.
    readonly property real desiredHeight: {
        const head = searchBar.implicitHeight + 16; // top+bottom margins
        if (!showResults) return head;
        const listMax = Appearance.island.launcherMaxHeight - head;
        const listH = Math.min(listMax, listView.contentHeight + listView.topMargin + listView.bottomMargin);
        return head + Math.max(0, listH);
    }

    signal activated

    function focusInput()  { searchBar.focusInput(); }
    function setText(t)    { searchBar.input.text = t; LauncherSearch.query = t; }
    function clear()       { searchBar.input.text = ""; LauncherSearch.query = ""; }
    function focusFirst()  { listView.currentIndex = 0; }
    function activateCurrent() {
        const cur = listView.currentItem;
        if (cur) cur.activated();
    }

    implicitHeight: column.implicitHeight
    implicitWidth: column.implicitWidth
    clip: true

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 0

        SearchBar {
            id: searchBar
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.topMargin: 8
            Layout.bottomMargin: 8
            Layout.minimumHeight: implicitHeight
            onAccepted: root.activateCurrent()
            onUpPressed: listView.decrementCurrentIndex()
            onDownPressed: listView.incrementCurrentIndex()
        }

        Item {
            visible: root.showResults && listView.count === 0
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 80 : 0
            StyledText {
                anchors.centerIn: parent
                text: qsTr("Nothing here D:")
                color: Appearance.colors.comment
                font.pixelSize: Appearance.typography.small
            }
        }

        ListView {
            id: listView
            visible: count > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 4
            Layout.rightMargin: 4
            Layout.bottomMargin: 8
            Layout.minimumHeight: 0
            clip: true
            topMargin: 6
            bottomMargin: 6
            spacing: 2
            highlightMoveDuration: 100
            keyNavigationEnabled: true
            interactive: true

            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: Appearance.motion.duration.medium3; easing.bezierCurve: Appearance.motion.easing.emphasized }
            }
            remove: Transition {
                NumberAnimation { property: "opacity"; from: 1; to: 0; duration: Appearance.motion.duration.long2; easing.bezierCurve: Appearance.motion.easing.emphasized }
            }
            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: Appearance.motion.duration.medium3; easing.bezierCurve: Appearance.motion.easing.emphasized }
            }

            model: ScriptModel {
                objectProp: "key"
                values: root.displayedResults
            }

            opacity: root.showResults ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.motion.duration.long2
                    easing.bezierCurve: Appearance.motion.easing.emphasized
                }
            }

            Connections {
                target: LauncherSearch
                function onResultsChanged() {
                    listView.currentIndex = 0;
                    Qt.callLater(() => listView.positionViewAtBeginning());
                }
            }

            delegate: SearchItem {
                required property var modelData
                required property int index
                width: ListView.view.width
                entry: modelData
                query: root.query.startsWith(LauncherSearch.clipboardPrefix)
                    ? root.query.slice(1)
                    : root.query
                selected: ListView.isCurrentItem
                onActivated: {
                    modelData.execute();
                    root.activated();
                }
            }
        }
    }
}
