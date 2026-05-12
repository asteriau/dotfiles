import QtQuick
import QtQuick.Layouts
import qs.components.controls
import qs.components.text
import qs.utils
import qs.services

// Shared resources detail panel — used by ResourcesBar's popup and by
// ResourcesExpansionContent in the expanded bar mode.
ColumnLayout {
    id: root
    width: 280
    spacing: 12

    Component.onCompleted: ResourcesState.subscribe()
    Component.onDestruction: ResourcesState.unsubscribe()

    StyledText {
        Layout.fillWidth: true
        text: "Resources"
        font.pixelSize: Config.typography.large
        font.weight: Font.Medium
        color: Appearance.colors.accent
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: "memory"
                pixelSize: 22
                color: Appearance.colors.foreground
            }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: (ResourcesState.memUsedStr || "0").split(" ")[0]
                font.pixelSize: Config.typography.larger
                font.weight: Font.Medium
                color: Appearance.colors.foreground
            }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: "/ " + (ResourcesState.memTotalStr || "0")
                font.pixelSize: Config.typography.small
                color: Appearance.colors.m3onSurfaceInactive
            }
            Item { Layout.fillWidth: true }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: "Memory"
                font.pixelSize: Config.typography.small
                color: Appearance.colors.m3onSurfaceInactive
            }
        }

        StyledCombinedProgressBar {
            Layout.fillWidth: true
            valueWeights: [ResourcesState.memoryTotal, ResourcesState.swapTotal]
            values: [ResourcesState.memoryUsedPercentage, ResourcesState.swapUsedPercentage]
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MaterialIcon {
                Layout.alignment: Qt.AlignVCenter
                text: "developer_board"
                pixelSize: 22
                color: Appearance.colors.foreground
            }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: Math.round(ResourcesState.cpuUsage * 100)
                font.pixelSize: Config.typography.larger
                font.weight: Font.Medium
                color: Appearance.colors.foreground
            }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: "%"
                font.pixelSize: Config.typography.small
                color: Appearance.colors.m3onSurfaceInactive
            }
            Item { Layout.fillWidth: true }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: "CPU"
                font.pixelSize: Config.typography.small
                color: Appearance.colors.m3onSurfaceInactive
            }
        }

        StyledCombinedProgressBar {
            Layout.fillWidth: true
            readonly property bool useSingleAggregate: ResourcesState.cpuCoreUsages.length > 8
            valueWeights: useSingleAggregate ? [1.0] : (ResourcesState.cpuCoreWeights.length > 0 ? ResourcesState.cpuCoreWeights : [1.0])
            values: useSingleAggregate ? [ResourcesState.cpuUsage] : (ResourcesState.cpuCoreUsages.length > 0 ? ResourcesState.cpuCoreUsages : [ResourcesState.cpuUsage])
        }
    }
}
