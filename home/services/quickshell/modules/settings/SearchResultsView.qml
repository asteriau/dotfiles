import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

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
        anchors.margins: Appearance.layout.pageMargin
        spacing: Appearance.layout.gapMd

        // Header line
        RowLayout {
            Layout.fillWidth: true
            spacing: Appearance.layout.gapMd

            StyledText {
                text: root._displayResults.length === 0
                    ? (root._displayQuery.length === 0 ? "" : "No results for “" + root._displayQuery + "”")
                    : root._displayResults.length + " result" + (root._displayResults.length === 1 ? "" : "s")
                      + " for “" + root._displayQuery + "”"
                color: Appearance.colors.m3onSurfaceVariant
                font.pixelSize: Appearance.typography.small
                Layout.fillWidth: true
            }
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root._displayResults
            spacing: Appearance.layout.gapMd
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
                radius: Appearance.layout.radiusLg
                color: Appearance.colors.transparent

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: index === root.selectedIndex ? Appearance.colors.secondaryContainer : Appearance.colors.hover
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
                    spacing: Appearance.layout.gapLg

                    // Tonal icon container
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignVCenter
                        radius: 18
                        color: Appearance.colors.colLayer2

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: root.pageIcons[delegateRoot.modelData.page] || "tune"
                            pixelSize: Appearance.typography.large
                            color: Appearance.colors.m3onSurfaceVariant
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        StyledText {
                            text: delegateRoot.modelData.label
                            color: Appearance.colors.foreground
                            font.pixelSize: Appearance.typography.small
                            font.weight: Font.Medium
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        StyledText {
                            visible: delegateRoot.modelData.caption.length > 0
                            text: delegateRoot.modelData.caption
                            color: Appearance.colors.m3onSurfaceVariant
                            font.pixelSize: Appearance.typography.smaller
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
                            color: Appearance.colors.m3onSurfaceVariant
                            font.pixelSize: Appearance.typography.small
                            font.weight: Font.Medium
                        }
                        MaterialIcon {
                            text: "chevron_right"
                            pixelSize: Appearance.typography.small
                            color: Appearance.colors.m3onSurfaceVariant
                        }
                        StyledText {
                            text: delegateRoot.modelData.section
                            color: Appearance.colors.m3onSurfaceVariant
                            font.pixelSize: Appearance.typography.small
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
