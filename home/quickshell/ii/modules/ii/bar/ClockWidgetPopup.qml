import qs.modules.common
import qs.modules.ii.sidebarRight.calendar
import QtQuick

StyledPopup {
    id: root

    // CalendarWidget sizes itself with width/implicitHeight; the popup reads implicit sizes
    Item {
        implicitWidth: calendar.width
        implicitHeight: calendar.implicitHeight

        CalendarWidget {
            id: calendar
        }
    }
}
