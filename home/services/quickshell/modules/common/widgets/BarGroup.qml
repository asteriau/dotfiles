import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property int  padding: Appearance.layout.gapSm
    property int  rowSpacing: Appearance.layout.gapMd
    property int  columnSpacing: Appearance.layout.gapSm
    property int  columns: -1
    property bool transparent: false

    // Tonal elevation level. "low" matches surfaceContainerLow (default),
    // "lowest" demotes (recedes), "container" promotes.
    property string tone: "low"
    readonly property color toneColor: tone === "lowest"    ? Appearance.colors.surfaceContainerLowest
                                     : tone === "container" ? Appearance.colors.surfaceContainer
                                     : tone === "high"      ? Appearance.colors.surfaceContainerHigh
                                                            : Appearance.colors.surfaceContainerLow
    property color bgColor: toneColor
    property int  radius: Appearance.layout.radiusContainer

    readonly property bool vertical: Config.bar.vertical

    default property alias content: grid.children

    implicitWidth:  vertical ? Appearance.bar.width
                             : grid.implicitWidth  + padding * 2
    implicitHeight: vertical ? grid.implicitHeight + padding * 2
                             : Appearance.bar.height

    Rectangle {
        anchors.fill: parent
        anchors.topMargin:    root.vertical ? 0 : Appearance.layout.gapSm
        anchors.bottomMargin: root.vertical ? 0 : Appearance.layout.gapSm
        anchors.leftMargin:   root.vertical ? Appearance.layout.gapSm : 0
        anchors.rightMargin:  root.vertical ? Appearance.layout.gapSm : 0
        radius: root.radius
        color: root.transparent ? "transparent" : root.bgColor

        Behavior on color {
            ColorAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic }
        }
    }

    Grid {
        id: grid
        anchors.centerIn: parent
        columns: root.vertical ? 1 : root.columns
        rowSpacing:    root.rowSpacing
        columnSpacing: root.columnSpacing
        verticalItemAlignment: Grid.AlignVCenter
    }
}
