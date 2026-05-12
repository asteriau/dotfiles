import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

IconButton {
    id: root

    radius: width / 2
    iconPixelSize: 22
    iconGrade: 0
    colorIdle: Appearance.colors.surfaceContainerHighest
    colorActiveHover: colorActive   // preserve original: no accent-lightening on hover

    Layout.preferredWidth:  Appearance.layout.pillSize - 8
    Layout.preferredHeight: Appearance.layout.pillSize - 8
    implicitWidth:  Appearance.layout.pillSize - 8
    implicitHeight: Appearance.layout.pillSize - 8
}
