import QtQuick
import qs.components.controls
import qs.components.surfaces
import qs.components.text
import qs.utils
import qs.services

PressablePill {
    id: root

    Component.onCompleted: ResourcesState.subscribe()
    Component.onDestruction: ResourcesState.unsubscribe()

    implicitWidth:  Config.bar.width - Config.layout.gapSm * 2
    implicitHeight: col.implicitHeight + 8

    radius: Config.layout.radiusContainer
    colorIdle: Colors.transparent
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
            value: ResourcesState.memoryUsedPercentage
            color: Colors.m3onSecondaryContainer
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: 20; height: 20
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "memory"
                    pixelSize: Config.typography.normal
                    color: Colors.m3onSecondaryContainer
                }
            }
        }

        CircularProgress {
            implicitSize: 20
            lineWidth: 2
            visible: ResourcesState.swapTotal > 0
            value: ResourcesState.swapUsedPercentage
            color: Colors.m3onSecondaryContainer
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: 20; height: 20
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "swap_horiz"
                    pixelSize: Config.typography.normal
                    color: Colors.m3onSecondaryContainer
                }
            }
        }

        CircularProgress {
            implicitSize: 20
            lineWidth: 2
            value: ResourcesState.cpuUsage
            color: Colors.m3onSecondaryContainer
            enableAnimation: true

            Item {
                anchors.centerIn: parent
                width: 20; height: 20
                MaterialIcon {
                    anchors.centerIn: parent
                    text: "planner_review"
                    pixelSize: Config.typography.normal
                    color: Colors.m3onSecondaryContainer
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
