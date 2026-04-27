import QtQuick.Layouts
import qs.components.surfaces
import qs.utils

IconButton {
    id: root

    radius: width / 2
    iconPixelSize: 24
    iconGrade: 0
    colorActiveHover: colorActive   // preserve original: no accent-lightening on hover

    Layout.preferredWidth:  Config.layout.pillSize
    Layout.preferredHeight: Config.layout.pillSize
    implicitWidth:  Config.layout.pillSize
    implicitHeight: Config.layout.pillSize
}
