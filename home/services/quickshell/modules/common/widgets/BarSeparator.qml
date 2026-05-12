import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

// 1px divider line. Auto-orients to the bar axis: in vertical bar it spans
// horizontally, in horizontal bar it spans vertically. Stretches to fill
// the bar cross-axis so Grid alignment doesn't mis-position it.
Item {
    readonly property bool vertical: Config.bar.vertical
    property int length: vertical ? 14 : 14

    implicitWidth:  vertical ? length : 1
    implicitHeight: vertical ? 1 : Appearance.bar.height

    Rectangle {
        anchors.centerIn: parent
        width:  vertical ? parent.width : 1
        height: vertical ? 1 : length
        color: Appearance.colors.outlineVariant
    }
}
