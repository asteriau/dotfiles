import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

// Shared resources detail panel — used by ResourcesBar's popup and by
// ResourcesExpansionContent in the expanded bar mode.
ColumnLayout {
    id: root
    width: 280
    spacing: 12

    Component.onCompleted: Resources.subscribe()
    Component.onDestruction: Resources.unsubscribe()

    StyledText {
        Layout.fillWidth: true
        text: "Resources"
        font.pixelSize: Appearance.typography.large
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
                text: (Resources.memUsedStr || "0").split(" ")[0]
                font.pixelSize: Appearance.typography.larger
                font.weight: Font.Medium
                color: Appearance.colors.foreground
            }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: "/ " + (Resources.memTotalStr || "0")
                font.pixelSize: Appearance.typography.small
                color: Appearance.colors.m3onSurfaceInactive
            }
            Item { Layout.fillWidth: true }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: "Memory"
                font.pixelSize: Appearance.typography.small
                color: Appearance.colors.m3onSurfaceInactive
            }
        }

        StyledCombinedProgressBar {
            Layout.fillWidth: true
            valueWeights: [Resources.memoryTotal, Resources.swapTotal]
            values: [Resources.memoryUsedPercentage, Resources.swapUsedPercentage]
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
                text: Math.round(Resources.cpuUsage * 100)
                font.pixelSize: Appearance.typography.larger
                font.weight: Font.Medium
                color: Appearance.colors.foreground
            }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: "%"
                font.pixelSize: Appearance.typography.small
                color: Appearance.colors.m3onSurfaceInactive
            }
            Item { Layout.fillWidth: true }
            StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: "CPU"
                font.pixelSize: Appearance.typography.small
                color: Appearance.colors.m3onSurfaceInactive
            }
        }

        StyledCombinedProgressBar {
            Layout.fillWidth: true
            readonly property bool useSingleAggregate: Resources.cpuCoreUsages.length > 8
            valueWeights: useSingleAggregate ? [1.0] : (Resources.cpuCoreWeights.length > 0 ? Resources.cpuCoreWeights : [1.0])
            values: useSingleAggregate ? [Resources.cpuUsage] : (Resources.cpuCoreUsages.length > 0 ? Resources.cpuCoreUsages : [Resources.cpuUsage])
        }
    }
}
