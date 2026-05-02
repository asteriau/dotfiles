import QtQuick
import qs.components.controls
import qs.components.text
import qs.utils
import qs.utils.state

MouseArea {
    id: root
    hoverEnabled: true
    acceptedButtons: Qt.NoButton

    implicitWidth:  col.implicitWidth
    implicitHeight: col.implicitHeight

    Column {
        id: col
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
        targetItem: root
        active: root.containsMouse

        Row {
            spacing: 12

            Column {
                spacing: 8
                BarPopupHeaderRow { icon: "memory"; label: "RAM" }
                Column {
                    spacing: 4
                    BarPopupValueRow { icon: "clock_loader_60"; label: "Used:";  value: ResourcesState.memUsedStr  }
                    BarPopupValueRow { icon: "check_circle";    label: "Free:";  value: ResourcesState.memFreeStr  }
                    BarPopupValueRow { icon: "empty_dashboard"; label: "Total:"; value: ResourcesState.memTotalStr }
                }
            }

            Column {
                visible: ResourcesState.swapTotal > 0
                spacing: 8
                BarPopupHeaderRow { icon: "swap_horiz"; label: "Swap" }
                Column {
                    spacing: 4
                    BarPopupValueRow { icon: "clock_loader_60"; label: "Used:";  value: ResourcesState.swapUsedStr  }
                    BarPopupValueRow { icon: "check_circle";    label: "Free:";  value: ResourcesState.swapFreeStr  }
                    BarPopupValueRow { icon: "empty_dashboard"; label: "Total:"; value: ResourcesState.swapTotalStr }
                }
            }

            Column {
                spacing: 8
                BarPopupHeaderRow { icon: "planner_review"; label: "CPU" }
                Column {
                    spacing: 4
                    BarPopupValueRow { icon: "bolt"; label: "Load:"; value: Math.round(ResourcesState.cpuUsage * 100) + "%" }
                }
            }
        }
    }
}
