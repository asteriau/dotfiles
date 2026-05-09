import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.components.text
import qs.utils
import qs.services

// Shared resources detail panel — used by ResourcesBar's popup and by
// ResourcesExpansionContent in the expanded bar mode.
Column {
    id: root
    width: 280
    spacing: 12

    Component.onCompleted: ResourcesState.subscribe()
    Component.onDestruction: ResourcesState.unsubscribe()

    StyledText {
        text: "Resources"
        font.pixelSize: Config.typography.large
        font.weight: Font.Medium
        color: Colors.accent
    }

    Column {
        width: parent.width
        spacing: 4

        Row {
            id: memRow
            width: parent.width
            spacing: 8

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: "memory"
                pixelSize: 22
                color: Colors.foreground
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: (ResourcesState.memUsedStr || "0").split(" ")[0]
                font.pixelSize: Config.typography.larger
                font.weight: Font.Medium
                color: Colors.foreground
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "/ " + (ResourcesState.memTotalStr || "0")
                font.pixelSize: Config.typography.small
                color: Colors.m3onSurfaceInactive
            }
            Item { width: parent.width - memRow.implicitWidth - 8; height: 1 }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "Memory"
                font.pixelSize: Config.typography.small
                color: Colors.m3onSurfaceInactive
            }
        }

        StyledCombinedProgressBar {
            width: parent.width
            valueWeights: [ResourcesState.memoryTotal, ResourcesState.swapTotal]
            values: [ResourcesState.memoryUsedPercentage, ResourcesState.swapUsedPercentage]
        }
    }

    Column {
        width: parent.width
        spacing: 4

        Row {
            id: cpuRow
            width: parent.width
            spacing: 8

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: "developer_board"
                pixelSize: 22
                color: Colors.foreground
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: Math.round(ResourcesState.cpuUsage * 100)
                font.pixelSize: Config.typography.larger
                font.weight: Font.Medium
                color: Colors.foreground
            }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "%"
                font.pixelSize: Config.typography.small
                color: Colors.m3onSurfaceInactive
            }
            Item { width: parent.width - cpuRow.implicitWidth - 8; height: 1 }
            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "CPU"
                font.pixelSize: Config.typography.small
                color: Colors.m3onSurfaceInactive
            }
        }

        StyledCombinedProgressBar {
            width: parent.width
            readonly property bool useSingleAggregate: ResourcesState.cpuCoreUsages.length > 8
            valueWeights: useSingleAggregate ? [1.0] : (ResourcesState.cpuCoreWeights.length > 0 ? ResourcesState.cpuCoreWeights : [1.0])
            values: useSingleAggregate ? [ResourcesState.cpuUsage] : (ResourcesState.cpuCoreUsages.length > 0 ? ResourcesState.cpuCoreUsages : [ResourcesState.cpuUsage])
        }
    }
}
