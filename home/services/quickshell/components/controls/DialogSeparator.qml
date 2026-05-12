import QtQuick
import QtQuick.Layouts
import qs.utils

// 1px hairline divider that bleeds past the dialog's content padding
// to span the full card width. `bleed` defaults to the dialog card
// radius (`Appearance.layout.radiusLg`) to match WindowDialog's padding.
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
