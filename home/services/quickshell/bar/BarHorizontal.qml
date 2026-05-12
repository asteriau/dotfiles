import QtQuick
import qs.components.controls
import qs.utils

Rectangle {
    id: root
    color: Colors.background
    radius: Config.bar.rounding ? Config.layout.radiusBar : 0

    Rectangle {
        visible: Config.bar.rounding
        width: root.radius; height: root.radius
        anchors.top:    Config.bar.onEnd ? undefined : parent.top
        anchors.bottom: Config.bar.onEnd ? parent.bottom : undefined
        anchors.left: parent.left
        color: Colors.background
    }
    Rectangle {
        visible: Config.bar.rounding
        width: root.radius; height: root.radius
        anchors.top:    Config.bar.onEnd ? undefined : parent.top
        anchors.bottom: Config.bar.onEnd ? parent.bottom : undefined
        anchors.right: parent.right
        color: Colors.background
    }

    // ── Nav ──────────────────────────────────────────────────────────────
    Row {
        anchors {
            left: parent.left
            leftMargin: Config.layout.zonePaddingH
            verticalCenter: parent.verticalCenter
        }
        spacing: Config.layout.barZoneGap

        SidebarToggle { anchors.verticalCenter: parent.verticalCenter }
        Workspaces    { anchors.verticalCenter: parent.verticalCenter }
    }

    // ── Focal ────────────────────────────────────────────────────────────
    ActiveWindow {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    // ── Status ───────────────────────────────────────────────────────────
    Row {
        anchors {
            right: parent.right
            rightMargin: Config.layout.zonePaddingH
            verticalCenter: parent.verticalCenter
        }
        spacing: Config.layout.barZoneGap

        Tray       { vertical: false; anchors.verticalCenter: parent.verticalCenter }
        Battery    { vertical: false; anchors.verticalCenter: parent.verticalCenter }
        WeatherBar { anchors.verticalCenter: parent.verticalCenter }

        Clock { anchors.verticalCenter: parent.verticalCenter }
    }
}
