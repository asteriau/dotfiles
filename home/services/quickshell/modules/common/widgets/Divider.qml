import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Rectangle {
    property bool vertical: false
    implicitWidth:  vertical ? 1 : 16
    implicitHeight: vertical ? 12 : 1
    color: Appearance.colors.divider
}
