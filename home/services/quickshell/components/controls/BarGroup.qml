import QtQuick
import qs.utils

// Pill container for bar widgets, mirroring ii's BarGroup. Default children
// flow inside an inner Grid; pass `columns: 1` for vertical stacking.
Item {
    id: root

    property int  padding: 5
    property int  rowSpacing: 8
    property int  columnSpacing: 4
    property int  columns: -1
    property bool transparent: false
    property color bgColor: Colors.surfaceContainerLow
    property int  radius: 12

    // Bar orientation drives the inset axis: bg hugs the long axis and leaves
    // a small gap on the short axis (matches ii's 4px short-edge breathing).
    readonly property bool vertical: Config.bar.vertical

    default property alias content: grid.children

    implicitWidth:  vertical ? Config.bar.width
                             : grid.implicitWidth  + padding * 2
    implicitHeight: vertical ? grid.implicitHeight + padding * 2
                             : Config.bar.height

    Rectangle {
        anchors.fill: parent
        anchors.topMargin:    root.vertical ? 0 : 4
        anchors.bottomMargin: root.vertical ? 0 : 4
        anchors.leftMargin:   root.vertical ? 4 : 0
        anchors.rightMargin:  root.vertical ? 4 : 0
        radius: root.radius
        color: root.transparent ? "transparent" : root.bgColor
    }

    Grid {
        id: grid
        anchors.centerIn: parent
        columns: root.vertical ? 1 : root.columns
        rowSpacing:    root.rowSpacing
        columnSpacing: root.columnSpacing
    }
}
