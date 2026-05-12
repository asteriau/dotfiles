import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property real padding: Appearance.layout.gapLg

    implicitWidth:  panel.implicitWidth + padding * 2
    implicitHeight: panel.implicitHeight + padding * 2

    CalendarPopup {
        id: panel
        x: root.padding
        y: root.padding
    }
}
