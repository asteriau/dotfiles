import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common

IconButton {
    id: root

    property real size: Appearance.layout.pillSize

    radius: width / 2
    iconPixelSize: Math.round(size * 0.4)
    iconGrade: 0
    colorIdle: Appearance.colors.surfaceContainerHighest
    colorActiveHover: colorActive
    colorIcon: Appearance.colors.foreground
    colorIconActive: Appearance.colors.background

    Layout.preferredWidth:  size
    Layout.preferredHeight: size
    implicitWidth:  size
    implicitHeight: size
}
