import qs.modules.common
import qs.modules.tachyon.sidebarRight.calendar
import QtQuick

StyledPopup {
    id: root

    // CalendarWidget sizes itself with width/implicitHeight; the popup reads implicit sizes
    Item {
        anchors.centerIn: parent
        implicitWidth: calendar.width
        implicitHeight: calendar.implicitHeight

        CalendarWidget {
            id: calendar
        }
    }
}
