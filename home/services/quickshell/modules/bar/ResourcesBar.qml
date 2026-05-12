import QtQuick
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

PressablePill {
    id: root

    Component.onCompleted: Resources.subscribe()
    Component.onDestruction: Resources.unsubscribe()

    implicitWidth:  Appearance.bar.width - Appearance.layout.gapSm * 2
    implicitHeight: col.implicitHeight + 8

    radius: Appearance.layout.radiusContainer
    colorIdle: Appearance.colors.transparent
    useStateLayer: true
    pressScale: 0.98

    onClicked: popup.active = !popup.active

    Column {
        id: col
        anchors.centerIn: parent
        spacing: 6

        CircularProgress {
            implicitSize: 20
            lineWidth: 2
            value: Resources.memoryUsedPercentage
            color: Appearance.colors.m3onSecondaryContainer
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: 20; height: 20
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "memory"
                    pixelSize: Appearance.typography.normal
                    color: Appearance.colors.m3onSecondaryContainer
                }
            }
        }

        CircularProgress {
            implicitSize: 20
            lineWidth: 2
            visible: Resources.swapTotal > 0
            value: Resources.swapUsedPercentage
            color: Appearance.colors.m3onSecondaryContainer
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: 20; height: 20
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "swap_horiz"
                    pixelSize: Appearance.typography.normal
                    color: Appearance.colors.m3onSecondaryContainer
                }
            }
        }

        CircularProgress {
            implicitSize: 20
            lineWidth: 2
            value: Resources.cpuUsage
            color: Appearance.colors.m3onSecondaryContainer
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: 20; height: 20
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "planner_review"
                    pixelSize: Appearance.typography.normal
                    color: Appearance.colors.m3onSecondaryContainer
                }
            }
        }
    }

    BarPopup {
        id: popup
        targetItem: root
        padding: 16

        ResourcesPanel {}
    }
}
