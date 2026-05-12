pragma ComponentBehavior: Bound

import QtQuick
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Rectangle {
    id: root

    required property int index

    // Inputs from the orchestrator.
    property real buttonWidth: 26
    property bool vertical: false
    property int  perGroup: 10
    property int  activeId: 1
    property bool activeWindowActivated: false
    property var  occupied: []

    readonly property real rFull: buttonWidth / 2

    readonly property bool prevOccupied:
        (index > 0 ? (occupied[index - 1] ?? false) : false) &&
        !(!activeWindowActivated && activeId === index)
    readonly property bool nextOccupied:
        (index < perGroup - 1 ? (occupied[index + 1] ?? false) : false) &&
        !(!activeWindowActivated && activeId === index + 2)
    readonly property bool occupiedVisible:
        (occupied[index] ?? false) &&
        !(!activeWindowActivated && activeId === index + 1)

    implicitWidth:  buttonWidth
    implicitHeight: buttonWidth

    // Corners flatten toward neighbors so a run of occupied workspaces reads as
    // one continuous pill. Horizontal run collapses on left/right;
    // vertical run collapses on top/bottom.
    topLeftRadius:     prevOccupied ? 0 : rFull
    bottomRightRadius: nextOccupied ? 0 : rFull
    topRightRadius:    (vertical ? prevOccupied : nextOccupied) ? 0 : rFull
    bottomLeftRadius:  (vertical ? nextOccupied : prevOccupied) ? 0 : rFull

    color: Appearance.colors.wsOrbFill
    opacity: occupiedVisible ? 1 : 0

    Behavior on opacity { Motion.Fade {} }
    Behavior on topLeftRadius { Motion.SpatialEmph {} }
    Behavior on bottomRightRadius { Motion.SpatialEmph {} }
    Behavior on topRightRadius { Motion.SpatialEmph {} }
    Behavior on bottomLeftRadius { Motion.SpatialEmph {} }
}
