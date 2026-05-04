pragma ComponentBehavior: Bound
import QtQuick
import qs.utils

AbstractCombinedProgressBar {
    id: root

    property real valueBarWidth: 120
    property real valueBarHeight: 2
    property real valueBarGap: 3
    property real valueBarInnerRadius: 2
    implicitWidth: valueBarWidth
    implicitHeight: valueBarHeight
    valueHighlights: [Colors.accent, Colors.mpris]
    valueTroughs: [Colors.secondaryContainer, Qt.rgba(Colors.mpris.r, Colors.mpris.g, Colors.mpris.b, 0.3)]

    background: Item {
        implicitWidth: root.valueBarWidth
        implicitHeight: root.valueBarHeight
    }

    function isNegligibleSegment(seg: var): bool {
        if (availableWidth <= 0) return false;
        const wdth = seg[1] - seg[0];
        const visualWidth = availableWidth * wdth;
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
