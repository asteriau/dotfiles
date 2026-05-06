pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components.text
import qs.launcher
import qs.utils

Item {
    id: root

    readonly property string query: LauncherSearch.query
    readonly property bool showResults: query !== ""

    property alias searchBar: searchBar
    property alias listView: listView

    function focusInput() { searchBar.focusInput(); }
    function disableExpandAnimation() { searchBar.animateWidth = false; }
    function enableExpandAnimation() { searchBar.animateWidth = true; }
    function setText(t) {
        searchBar.input.text = t;
        LauncherSearch.query = t;
    }
    function clear() {
        searchBar.input.text = "";
        LauncherSearch.query = "";
    }
    function focusFirst() {
        listView.currentIndex = 0;
    }

    signal activated

    implicitWidth: card.implicitWidth + 24
    implicitHeight: card.implicitHeight + 24

    Rectangle {
        id: shadow
        anchors.fill: card
        radius: card.radius
        color: "transparent"
        layer.enabled: true
    }

    Rectangle {
        id: card
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: 12
        }
        clip: true
        radius: 26
        color: Colors.surfaceContainer
        implicitWidth: column.implicitWidth
        implicitHeight: column.implicitHeight

        Behavior on implicitHeight {
            enabled: root.showResults
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: column
            spacing: 0

            SearchBar {
                id: searchBar
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                Layout.topMargin: 6
                Layout.bottomMargin: 6
                onAccepted: {
                    const cur = listView.currentItem;
                    if (cur) cur.activated();
                }
            }

            Rectangle {
                visible: root.showResults
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Colors.outlineVariant
            }

            Item {
                visible: root.showResults && listView.count === 0
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? 80 : 0
                StyledText {
                    anchors.centerIn: parent
                    text: "Nothing here D:"
                    color: Colors.comment
                    font.pixelSize: Config.typography.small
                }
            }

            ListView {
                id: listView
                visible: root.showResults && count > 0
                Layout.fillWidth: true
                Layout.preferredHeight: visible ? Math.min(560, contentHeight + topMargin + bottomMargin) : 0
                clip: true
                topMargin: 8
                bottomMargin: 8
                spacing: 2
                highlightMoveDuration: 100
                keyNavigationEnabled: true
                interactive: true

                model: ScriptModel {
                    id: resultModel
                    objectProp: "key"
                    values: LauncherSearch.results.slice(0, 15)
                }

                Connections {
                    target: LauncherSearch
                    function onResultsChanged() {
                        listView.currentIndex = 0;
                    }
                }

                delegate: SearchItem {
                    id: item
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
}
