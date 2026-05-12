import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property real padding: 12

    implicitWidth:  panel.implicitWidth + padding * 2
    implicitHeight: panel.implicitHeight + padding * 2

    CalendarPanel {
        id: panel
        x: root.padding
        y: root.padding
    }
}
