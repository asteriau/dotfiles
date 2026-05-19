import qs.modules.common
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    default property alias groupData: rowLayout.data
    property alias uniformCellSizes: rowLayout.uniformCellSizes
    property real spacing: 5
    property real padding: 0
    property alias clickIndex: rowLayout.clickIndex
    property alias childrenCount: rowLayout.childrenCount

    property real contentWidth: {
        let total = 0;
        for (let i = 0; i < rowLayout.children.length; ++i) {
            const child = rowLayout.children[i];
            if (!child.visible)
                continue;
            total += child.baseWidth ?? child.implicitWidth ?? child.width;
        }
        return total + rowLayout.spacing * (rowLayout.children.length - 1);
    }

    topLeftRadius: rowLayout.children.length > 0 ? (rowLayout.children[0].radius + padding) :
                                                   Appearance.layout.radiusMd
    bottomLeftRadius: topLeftRadius
    topRightRadius: rowLayout.children.length > 0 ? (rowLayout.children[rowLayout.children.length - 1].radius
                                                     + padding) : Appearance.layout.radiusMd
    bottomRightRadius: topRightRadius

    color: "transparent"
    width: root.contentWidth + padding * 2
    implicitHeight: rowLayout.implicitHeight + padding * 2
    implicitWidth: root.contentWidth + padding * 2

    children: [
        RowLayout {
            id: rowLayout
            anchors.fill: parent
            anchors.margins: root.padding
            spacing: root.spacing
            property int clickIndex: -1
            property int childrenCount: children.length
        }
    ]
}
