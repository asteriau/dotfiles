import QtQuick
import qs.components.controls
import qs.utils

Rectangle {
    id: root
    color: Colors.background

    // ── Nav ──────────────────────────────────────────────────────────────
    Row {
        anchors {
            left: parent.left
            leftMargin: Config.layout.gapLg
            verticalCenter: parent.verticalCenter
        }
        spacing: Config.layout.barZoneGap

        SidebarToggle { anchors.verticalCenter: parent.verticalCenter }
        Workspaces    { anchors.verticalCenter: parent.verticalCenter }
    }

    // ── Focal ────────────────────────────────────────────────────────────
    FocalSlot {
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }
    }

    // ── Status ───────────────────────────────────────────────────────────
    Row {
        anchors {
            right: parent.right
            rightMargin: Config.layout.gapLg
            verticalCenter: parent.verticalCenter
        }
        spacing: Config.layout.barZoneGap

        WeatherBar { anchors.verticalCenter: parent.verticalCenter }
        Tray       { vertical: false; anchors.verticalCenter: parent.verticalCenter }

        BarGroup {
            anchors.verticalCenter: parent.verticalCenter
            tone: "low"
            columnSpacing: Config.layout.gapMd

            Connectivity {}
            Battery { vertical: false }
            Clock {}
        }
    }
}
