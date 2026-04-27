import QtQuick.Layouts
import qs.components.surfaces
import qs.utils

IconButton {
    id: root

    radius: Config.layout.radiusXl
    iconPixelSize: 22
    iconWeight: 400                  // TileSmall: no weight change on active
    iconGrade: 0
    colorActiveHover: colorActive    // preserve original: no hover-lightening when active

    Layout.fillWidth: true
    Layout.preferredHeight: width
    implicitWidth:  Config.layout.tileSize
    implicitHeight: Config.layout.tileSize
}
