import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

StyledPopup {
    id: root

    // StyledPopup sizes itself from implicit sizes, which a ColumnLayout with
    // fillWidth rows underreports, so the width is pinned here
    Item {
        implicitWidth: 280
        implicitHeight: column.implicitHeight

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 16

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Resources")
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: Font.Medium
                color: Appearance.colors.colPrimary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: "memory"
                        iconSize: 22
                        color: Appearance.colors.colOnLayer1
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignBaseline
                        text: ResourceUsage.kbToGbString(ResourceUsage.memoryUsed).split(" ")[0]
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer1
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignBaseline
                        text: "/ " + ResourceUsage.maxAvailableMemoryString
                        font.pixelSize: Appearance.font.pixelSize.smallie
                        color: Appearance.colors.colSubtext
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignBaseline
                        text: Translation.tr("Memory")
                        font.pixelSize: Appearance.font.pixelSize.smallie
                        color: Appearance.colors.colSubtext
                    }
                }

                StyledCombinedProgressBar {
                    Layout.fillWidth: true
                    valueWeights: [ResourceUsage.memoryTotal, ResourceUsage.swapTotal]
                    values: [ResourceUsage.memoryUsedPercentage, ResourceUsage.swapUsedPercentage]
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MaterialSymbol {
                        Layout.alignment: Qt.AlignVCenter
                        text: "developer_board"
                        iconSize: 22
                        color: Appearance.colors.colOnLayer1
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignBaseline
                        text: Math.round(ResourceUsage.cpuUsage * 100)
                        font.pixelSize: Appearance.font.pixelSize.larger
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnLayer1
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignBaseline
                        text: "%"
                        font.pixelSize: Appearance.font.pixelSize.smallie
                        color: Appearance.colors.colSubtext
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignBaseline
                        text: "CPU"
                        font.pixelSize: Appearance.font.pixelSize.smallie
                        color: Appearance.colors.colSubtext
                    }
                }

                StyledCombinedProgressBar {
                    Layout.fillWidth: true
                    // one segment per core up to 8, else a single aggregate bar
                    readonly property bool perCore: ResourceUsage.cpuCoreUsages.length > 0 && ResourceUsage.cpuCoreUsages.length <= 8
                    valueWeights: perCore ? ResourceUsage.cpuCoreUsages.map(() => 1) : [1]
                    values: perCore ? ResourceUsage.cpuCoreUsages : [ResourceUsage.cpuUsage]
                    valueHighlights: [Appearance.colors.colPrimary]
                    valueTroughs: [Appearance.colors.colSecondaryContainer]
                }
            }
        }
    }
}
