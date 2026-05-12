import QtQuick.Layouts
import qs.components.surfaces
import qs.utils

IconButton {
    id: root

    radius: width / 2
    iconPixelSize: 22
    iconGrade: 0
    colorIdle: Appearance.colors.surfaceContainerHighest
    colorActiveHover: colorActive   // preserve original: no accent-lightening on hover

    Layout.preferredWidth:  Config.layout.pillSize - 8
    Layout.preferredHeight: Config.layout.pillSize - 8
    implicitWidth:  Config.layout.pillSize - 8
    implicitHeight: Config.layout.pillSize - 8
}
