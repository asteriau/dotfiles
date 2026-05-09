import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.components.controls
import qs.utils

PanelWindow {
    id: barWindow
    WlrLayershell.namespace: "quickshell:bar"
    screen: UiState.preferredMonitor

    anchors {
        top:    Config.bar.vertical || !Config.bar.onEnd
        bottom: Config.bar.vertical || Config.bar.onEnd
        left:   !Config.bar.vertical || !Config.bar.onEnd
        right:  !Config.bar.vertical || Config.bar.onEnd
    }
    implicitWidth:  Config.bar.vertical ? Config.bar.width : 0
    implicitHeight: Config.bar.vertical ? 0 : Config.bar.height

    color: "transparent"

    // Vertical: nav (top) · focal (center) · status (bottom).
    Item {
        visible: Config.bar.vertical
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: Colors.background
            visible: !Config.bar.rounding
        }

        BarShape {
            anchors.fill: parent
            bodyWidth:    parent.width
            bodyHeight:   parent.height
            onEnd:        Config.bar.onEnd
            screenRadius: 0
            freeRadius:   Config.bar.cornerRadius
            fillColor:    Colors.background
            visible:      Config.bar.rounding
        }

        // ── Nav ──────────────────────────────────────────────────────────
        Item {
            id: navZone
            anchors {
                top: parent.top
                topMargin: Config.layout.zonePaddingV
                horizontalCenter: parent.horizontalCenter
            }
            implicitWidth: sidebarToggle.implicitWidth
            implicitHeight: sidebarToggle.implicitHeight

            SidebarToggle { id: sidebarToggle }
        }

        // ── Center: resources · workspaces · clock ───────────────────────
        ColumnLayout {
            id: centerZone
            anchors {
                verticalCenter: parent.verticalCenter
                horizontalCenter: parent.horizontalCenter
            }
            spacing: Config.layout.barZoneGap

            BarGroup {
                Layout.alignment: Qt.AlignHCenter
                tone: "low"
                padding: 0

                ResourcesBar {}
            }
            Workspaces   { Layout.alignment: Qt.AlignHCenter }

            BarGroup {
                Layout.alignment: Qt.AlignHCenter
                tone: "low"
                rowSpacing: Config.layout.gapMd
                padding: 0

                Clock {}
            }
        }

        // ── Status ───────────────────────────────────────────────────────
        ColumnLayout {
            id: statusZone
            anchors {
                bottom: parent.bottom
                bottomMargin: Config.layout.zonePaddingV
                horizontalCenter: parent.horizontalCenter
            }
            spacing: Config.layout.barZoneGap

            BarGroup {
                id: batteryGroup
                Layout.alignment: Qt.AlignHCenter
                tone: "low"
                rowSpacing: Config.layout.gapMd
                transparent: !battery.low
                bgColor: battery.low
                    ? ColorMix.mix(Colors.red, toneColor, 0.2)
                    : toneColor

                Battery { id: battery }
            }

            Tray { Layout.alignment: Qt.AlignHCenter }
        }
    }

    BarHorizontal {
        visible: !Config.bar.vertical
        anchors.fill: parent
    }
}
