import QtQuick
import qs.utils

// Pill container for bar widgets. Default children flow inside an inner Grid;
// pass `columns: 1` for vertical stacking. Tonal level via `tone`.
Item {
    id: root

    property int  padding: Config.layout.gapSm
    property int  rowSpacing: Config.layout.gapMd
    property int  columnSpacing: Config.layout.gapSm
    property int  columns: -1
    property bool transparent: false

    // Tonal elevation level. "low" matches surfaceContainerLow (default),
    // "lowest" demotes (recedes), "container" promotes.
    property string tone: "low"
    readonly property color toneColor: tone === "lowest"    ? Colors.surfaceContainerLowest
                                     : tone === "container" ? Colors.surfaceContainer
                                     : tone === "high"      ? Colors.surfaceContainerHigh
                                                            : Colors.surfaceContainerLow
    property color bgColor: toneColor
    property int  radius: Config.layout.radiusMd

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

        Behavior on color {
            ColorAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic }
        }
    }

    Grid {
        id: grid
        anchors.centerIn: parent
        columns: root.vertical ? 1 : root.columns
        rowSpacing:    root.rowSpacing
        columnSpacing: root.columnSpacing
    }
}
