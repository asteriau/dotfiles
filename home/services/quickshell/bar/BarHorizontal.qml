import QtQuick
import qs.components.controls
import qs.utils

Rectangle {
    id: root
    color: Appearance.colors.background
    radius: Config.bar.rounding ? Appearance.layout.radiusBar : 0

    Rectangle {
        visible: Config.bar.rounding
        width: root.radius; height: root.radius
        anchors.top:    Config.bar.onEnd ? undefined : parent.top
        anchors.bottom: Config.bar.onEnd ? parent.bottom : undefined
        anchors.left: parent.left
        color: Appearance.colors.background
    }
    Rectangle {
        visible: Config.bar.rounding
        width: root.radius; height: root.radius
        anchors.top:    Config.bar.onEnd ? undefined : parent.top
        anchors.bottom: Config.bar.onEnd ? parent.bottom : undefined
        anchors.right: parent.right
        color: Appearance.colors.background
    }

    // ── Nav ──────────────────────────────────────────────────────────────
    Row {
        anchors {
            left: parent.left
            leftMargin: Appearance.layout.zonePaddingH
            verticalCenter: parent.verticalCenter
        }
        spacing: Appearance.layout.barZoneGap

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
            rightMargin: Appearance.layout.zonePaddingH
            verticalCenter: parent.verticalCenter
        }
        spacing: Appearance.layout.barZoneGap

        Tray       { vertical: false; anchors.verticalCenter: parent.verticalCenter }
        Battery    { vertical: false; anchors.verticalCenter: parent.verticalCenter }
        WeatherBar { anchors.verticalCenter: parent.verticalCenter }

        Clock { anchors.verticalCenter: parent.verticalCenter }
    }
}
