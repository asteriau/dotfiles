import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

Item {
    id: root

    property var results: []         // array of entry objects from searchData.search()
    property string query: ""
    property int selectedIndex: 0

    // Shadow model: keeps last non-empty results while overlay fades out so
    // delegates don't vanish before the fade completes.
    property var _displayResults: []
    property string _displayQuery: ""
    onResultsChanged: {
        if (results.length > 0) {
            _displayResults = results;
            _displayQuery = query;
        }
        selectedIndex = 0;
    }
    onOpacityChanged: {
        if (opacity === 0) {
            _displayResults = [];
            _displayQuery = "";
        }
    }

    signal activated(var entry)

    readonly property var pageIcons: ({
        "Bar":     "dock_to_left",
        "Theme":   "palette",
        "General": "tune",
        "About":   "info"
    })

    function moveSelection(delta) {
        if (results.length === 0) return;
        var n = results.length;
        selectedIndex = ((selectedIndex + delta) % n + n) % n;
        listView.positionViewAtIndex(selectedIndex, ListView.Contain);
    }

    function activateSelected() {
        if (results.length === 0) return;
        var entry = results[selectedIndex];
        if (entry) root.activated(entry);
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Config.layout.pageMargin
        spacing: Config.layout.gapMd

        // Header line
        RowLayout {
            Layout.fillWidth: true
            spacing: Config.layout.gapMd

            StyledText {
                text: root._displayResults.length === 0
                    ? (root._displayQuery.length === 0 ? "" : "No results for “" + root._displayQuery + "”")
                    : root._displayResults.length + " result" + (root._displayResults.length === 1 ? "" : "s")
                      + " for “" + root._displayQuery + "”"
                color: Colors.m3onSurfaceVariant
                font.pixelSize: Config.typography.small
                Layout.fillWidth: true
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root._displayResults
            spacing: Config.layout.gapMd
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            currentIndex: root.selectedIndex
            highlightFollowsCurrentItem: true

            delegate: Rectangle {
                id: delegateRoot
                required property int index
                required property var modelData
                width: ListView.view.width
                implicitHeight: Math.max(64, rowCol.implicitHeight + 24)
                radius: Config.layout.radiusLg
                color: Colors.transparent

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: index === root.selectedIndex ? Colors.secondaryContainer : Colors.hover
                    opacity: index === root.selectedIndex ? 1 : (ma.containsMouse ? 1 : 0)
                    Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
                }

                RowLayout {
                    id: rowCol
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    anchors.topMargin: 12
                    anchors.bottomMargin: 12
                    spacing: Config.layout.gapLg

                    // Tonal icon container
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignVCenter
                        radius: 18
                        color: Colors.colLayer2

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: root.pageIcons[delegateRoot.modelData.page] || "tune"
                            pixelSize: Config.typography.large
                            color: Colors.m3onSurfaceVariant
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        StyledText {
                            text: delegateRoot.modelData.label
                            color: Colors.foreground
                            font.pixelSize: Config.typography.small
                            font.weight: Font.Medium
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        StyledText {
                            visible: delegateRoot.modelData.caption.length > 0
                            text: delegateRoot.modelData.caption
                            color: Colors.m3onSurfaceVariant
                            font.pixelSize: Config.typography.smaller
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    // Page › Section breadcrumb
                    RowLayout {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 4

                        StyledText {
                            text: delegateRoot.modelData.page
                            color: Colors.m3onSurfaceVariant
                            font.pixelSize: Config.typography.small
                            font.weight: Font.Medium
                        }
                        MaterialIcon {
                            text: "chevron_right"
                            pixelSize: Config.typography.small
                            color: Colors.m3onSurfaceVariant
                        }
                        StyledText {
                            text: delegateRoot.modelData.section
                            color: Colors.m3onSurfaceVariant
                            font.pixelSize: Config.typography.small
                        }
                    }
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selectedIndex = delegateRoot.index;
                        root.activated(delegateRoot.modelData);
                    }
                }
            }
        }
    }
}
