import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Rectangle {
    id: root

    property real bleed: Appearance.layout.radiusLg

    Layout.fillWidth: true
    Layout.topMargin: -8
    Layout.bottomMargin: -8
    Layout.leftMargin: -bleed
    Layout.rightMargin: -bleed
    implicitHeight: 1
    color: Appearance.colors.outlineVariant
}
