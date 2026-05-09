import QtQuick
import QtQuick.Layouts
import qs.components.text
import qs.utils

Item {
    id: root

    property string pageName: ""
    property bool compact: false
    property real searchOffsetX: 0
    property alias searchText: searchField.text
    property alias searchField: searchField

    signal queryChanged(string q)
    signal submitted
    signal escapePressed
    signal arrowDown
    signal arrowUp

    function focusSearch() { searchField.focusInput(); }
    function clearSearch() { searchField.clearText(); }

    implicitHeight: 64

    // Breadcrumb pinned to the left edge.
    RowLayout {
        id: breadcrumb
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Config.layout.gapLg
        spacing: Config.layout.gapMd
        visible: !root.compact
        opacity: root.compact ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }

        StyledText {
            text: "Settings"
            color: Colors.m3onSurfaceVariant
            font.pixelSize: Config.typography.larger
            font.weight: Font.Medium
            font.family: Config.typography.titleFamily
        }

        MaterialIcon {
            text: "chevron_right"
            font.pointSize: Config.typography.huge
            color: Colors.m3onSurfaceVariant
            opacity: 0.7
        }

        CrossfadeText {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: 28
            Layout.preferredWidth: 140
            text: root.pageName
            pixelSize: Config.typography.larger
            fontWeight: Font.Medium
            color: Colors.accent
        }
    }

    // Search field absolutely centered in the header (independent of breadcrumb width).
    SettingsSearchField {
        id: searchField
        width: Math.min(480, root.width - 32)
        height: 44
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: root.searchOffsetX
        anchors.verticalCenter: parent.verticalCenter
        Behavior on anchors.horizontalCenterOffset {
            NumberAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.OutCubic }
        }

        onQueryChanged: q => root.queryChanged(q)
        onSubmitted: root.submitted()
        onEscapePressed: root.escapePressed()
        onArrowDown: root.arrowDown()
        onArrowUp: root.arrowUp()
    }
}
