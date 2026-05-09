import QtQuick
import QtQuick.Layouts
import qs.utils

// Full-bleed list row used inside dialog ListViews. Provides hover
// background, primary + alt click signals, and exposes
// `horizontalPadding` / `verticalPadding` so consumers can lay out
// their RowLayout/ColumnLayout content with consistent margins.
Item {
    id: root

    property real horizontalPadding: 16
    property real verticalPadding: 12
    property bool active: false
    property bool enabled: true
    property real contentHeight: contentLayer.implicitHeight

    default property alias contentData: contentLayer.data

    signal clicked
    signal altClicked

    Layout.fillWidth: true
    implicitHeight: contentHeight

    Rectangle {
        anchors.fill: parent
        color: ma.containsMouse
            ? Qt.rgba(Colors.m3onSurface.r, Colors.m3onSurface.g, Colors.m3onSurface.b, 0.05)
            : "transparent"
        Behavior on color { Motion.ColorFade {} }
    }

    Item {
        id: contentLayer
        anchors.fill: parent
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: root.enabled
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.enabled
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (m) => {
            if (m.button === Qt.RightButton) root.altClicked();
            else root.clicked();
        }
    }
}
