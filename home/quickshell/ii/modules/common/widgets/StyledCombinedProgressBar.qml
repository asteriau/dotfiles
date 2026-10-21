pragma ComponentBehavior: Bound
import QtQuick
import qs.modules.common

// Several values side by side in one bar, each with its own fill and trough
// (e.g. memory next to swap, or one segment per CPU core).
AbstractCombinedProgressBar {
    id: root

    property real valueBarWidth: 120
    property real valueBarHeight: 2
    property real valueBarGap: 3
    property real valueBarInnerRadius: 2
    implicitWidth: valueBarWidth
    implicitHeight: valueBarHeight
    valueHighlights: [Appearance.colors.colPrimary, Appearance.colors.colTertiary]
    valueTroughs: [Appearance.colors.colSecondaryContainer, Appearance.colors.colTertiaryContainer]

    background: Item {
        implicitWidth: root.valueBarWidth
        implicitHeight: root.valueBarHeight
    }

    function isNegligibleSegment(seg: var): bool {
        if (availableWidth <= 0) return false;
        const visualWidth = availableWidth * (seg[1] - seg[0]);
        return (visualWidth <= valueBarGap + valueBarHeight)
    }

    contentItem: Item {
        anchors.fill: parent
        Repeater {
            model: root.visualSegments

            delegate: Rectangle {
                required property int index
                required property var modelData

                visible: !root.isNegligibleSegment(modelData)
                property bool atStart: index == 0
                property bool atEnd: index == root.visualSegments.length - 1
                property real displaySegStart: {
                    var i = index;
                    while ((i > 0 && root.isNegligibleSegment(root.visualSegments[i-1])))
                        i--;
                    return root.visualSegments[i][0]
                }

                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }

                x: {
                    var result = root.availableWidth * displaySegStart;
                    if (!atStart) result += root.valueBarGap / 2;
                    return result;
                }
                width: {
                    var result = root.availableWidth * (modelData[1] - displaySegStart)
                    if (atStart || atEnd) result -= root.valueBarGap / 2;
                    else result -= root.valueBarGap;
                    return result;
                }
                color: root.segmentColors[index % root.segmentColors.length]

                property real startRadius: atStart ? height / 2 : root.valueBarInnerRadius
                property real endRadius: atEnd ? height / 2 : root.valueBarInnerRadius

                topLeftRadius: startRadius
                bottomLeftRadius: startRadius
                topRightRadius: endRadius
                bottomRightRadius: endRadius
            }
        }
    }
}
