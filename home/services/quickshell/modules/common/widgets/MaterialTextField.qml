import QtQuick
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

TextField {
    id: root

    property bool hasError: false

    color: Appearance.colors.colOnLayer2
    placeholderTextColor: Appearance.colors.m3onSurfaceInactive
    selectionColor: Appearance.colors.colPrimary
    selectedTextColor: Appearance.colors.colOnPrimary
    font.family: "Inter"
    font.pixelSize: Appearance.typography.smallie
    leftPadding: 10
    rightPadding: 10
    topPadding: 8
    bottomPadding: 8
    selectByMouse: true

    background: Rectangle {
        radius: Appearance.layout.radiusSm
        color: Appearance.colors.colLayer3
        border.width: 1
        border.color: root.hasError
            ? Qt.rgba(0.92, 0.45, 0.45, 1)
            : (root.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.outlineVariant)

        Behavior on border.color { ColorAnimation { duration: 120 } }
    }
}
