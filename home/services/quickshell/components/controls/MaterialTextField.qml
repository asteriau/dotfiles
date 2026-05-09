import QtQuick
import QtQuick.Controls
import qs.utils

// Minimal MD3-flavored text field. Used for inline wifi password entry.
TextField {
    id: root

    property bool hasError: false

    color: Colors.colOnLayer2
    placeholderTextColor: Colors.m3onSurfaceInactive
    selectionColor: Colors.colPrimary
    selectedTextColor: Colors.colOnPrimary
    font.family: "Inter"
    font.pixelSize: 13
    leftPadding: 10
    rightPadding: 10
    topPadding: 8
    bottomPadding: 8
    selectByMouse: true

    background: Rectangle {
        radius: Config.layout.radiusSm
        color: Colors.colLayer3
        border.width: 1
        border.color: root.hasError
            ? Qt.rgba(0.92, 0.45, 0.45, 1)
            : (root.activeFocus ? Colors.colPrimary : Colors.outlineVariant)

        Behavior on border.color { ColorAnimation { duration: 120 } }
    }
}
