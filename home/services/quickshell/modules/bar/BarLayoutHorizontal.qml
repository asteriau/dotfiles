import QtQuick
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

// Horizontal bar *content only*. The flat background is BarBackground,
// rendered by BarShell BELOW the morph layer so these widgets sit on top of
// the morph shape (faithful hefty layering — clock/weather stay visible while
// a popout grows out of the bar, and ActiveWindow is never overdrawn).
Item {
    id: root

    Row {
        anchors {
            left: parent.left
            leftMargin: Appearance.layout.zonePaddingH
            verticalCenter: parent.verticalCenter
        }
        spacing: Appearance.layout.barZoneGap

        SidebarToggle {
            anchors.verticalCenter: parent.verticalCenter
        }
        Workspaces {
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    ActiveWindow {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    Row {
        anchors {
            right: parent.right
            rightMargin: Appearance.layout.zonePaddingH
            verticalCenter: parent.verticalCenter
        }
        spacing: Appearance.layout.clusterGap

        Tray {
            vertical: false
            cluster: "start"
            anchors.verticalCenter: parent.verticalCenter
        }
        WeatherBar {
            cluster: "mid"
            anchors.verticalCenter: parent.verticalCenter
        }
        Battery {
            vertical: false
            cluster: "mid"
            anchors.verticalCenter: parent.verticalCenter
        }
        Clock {
            cluster: "end"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
