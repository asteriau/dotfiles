import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

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
