pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.components
import qs.utils

Item {
    id: root

    property bool vertical: Config.barVertical

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property int effectiveActiveWorkspaceId: monitor?.activeWorkspace?.id ?? 1
    readonly property int workspacesShown: Config.workspacesShown
    readonly property int workspaceGroup: Math.floor((effectiveActiveWorkspaceId - 1) / workspacesShown)
    readonly property int workspaceIndexInGroup: (effectiveActiveWorkspaceId - 1) % workspacesShown

    property list<bool> workspaceOccupied: []

    readonly property int workspaceButtonWidth: 26
    readonly property real activeWorkspaceMargin: 2
    readonly property real workspaceIconSize: workspaceButtonWidth * 0.69
    readonly property real workspaceIconSizeShrinked: workspaceButtonWidth * 0.55
    readonly property real workspaceIconMarginShrinked: -4
    readonly property int verticalPadding: 4

    readonly property bool showNumbers: Config.showWorkspaceNumbers

    property int scrollAccumulator: 0

    implicitWidth:  vertical ? Config.barWidth : (workspaceButtonWidth * workspacesShown)
    implicitHeight: vertical ? (workspaceButtonWidth * workspacesShown + verticalPadding * 2) : Config.barHeight

    // Elevated background
    Rectangle {
        z: 0
        anchors.fill: parent
        radius: 12
        color: Colors.elevated
    }

    function updateWorkspaceOccupied() {
        workspaceOccupied = Array.from({ length: workspacesShown }, (_, i) =>
            Hyprland.workspaces.values.some(ws =>
                ws.id === workspaceGroup * workspacesShown + i + 1));
    }

    Component.onCompleted: updateWorkspaceOccupied()

    Connections {
        target: Hyprland.workspaces
        function onValuesChanged() { root.updateWorkspaceOccupied(); }
    }
    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() { root.updateWorkspaceOccupied(); }
    }
    onWorkspaceGroupChanged: updateWorkspaceOccupied()

    // Scroll to switch workspaces
    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y < 0)
                Hyprland.dispatch("workspace r+1");
            else if (event.angleDelta.y > 0)
                Hyprland.dispatch("workspace r-1");
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    // ── z:1 — Occupied workspace background tiles ──────────────────────────
    Grid {
        z: 1
        anchors.centerIn: parent
        rowSpacing: 0
        columnSpacing: 0
        columns: vertical ? 1 : root.workspacesShown
        rows:    vertical ? root.workspacesShown : 1

        Repeater {
            model: root.workspacesShown

            Rectangle {
                id: occupiedTile
                required property int index

                readonly property bool prevOccupied:
                    (root.workspaceOccupied[index - 1] ?? false) &&
                    !(!root.activeWindow?.activated && root.effectiveActiveWorkspaceId === index)
                readonly property bool nextOccupied:
                    (root.workspaceOccupied[index + 1] ?? false) &&
                    !(!root.activeWindow?.activated && root.effectiveActiveWorkspaceId === index + 2)

                readonly property real rFull: root.workspaceButtonWidth / 2

                implicitWidth:  root.workspaceButtonWidth
                implicitHeight: root.workspaceButtonWidth

                topLeftRadius:     root.vertical ? (prevOccupied ? 0 : rFull) : (prevOccupied ? 0 : rFull)
                bottomLeftRadius:  root.vertical ? (nextOccupied ? 0 : rFull) : (prevOccupied ? 0 : rFull)
                topRightRadius:    root.vertical ? (prevOccupied ? 0 : rFull) : (nextOccupied ? 0 : rFull)
                bottomRightRadius: root.vertical ? (nextOccupied ? 0 : rFull) : (nextOccupied ? 0 : rFull)

                color: Colors.secondaryContainer

                opacity: (root.workspaceOccupied[index] ?? false) &&
                         !(!root.activeWindow?.activated &&
                           root.effectiveActiveWorkspaceId === index + 1) ? 1 : 0

                Behavior on opacity       { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized } }
                Behavior on topLeftRadius { NumberAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized } }
                Behavior on bottomRightRadius { NumberAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized } }
            }
        }
    }

    // ── z:2 — Animated active workspace pill ──────────────────────────────
    Rectangle {
        z: 2
        radius: root.workspaceButtonWidth / 2
        color: Colors.accent

        anchors {
            verticalCenter:   root.vertical ? undefined : parent.verticalCenter
            horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
        }

        AnimatedTabPair {
            id: tabPair
            index: root.workspaceIndexInGroup
        }

        readonly property real indicatorPos:
            Math.min(tabPair.idx1, tabPair.idx2) * root.workspaceButtonWidth + root.activeWorkspaceMargin +
            (root.vertical ? root.verticalPadding : 0)
        readonly property real indicatorLen:
            Math.abs(tabPair.idx1 - tabPair.idx2) * root.workspaceButtonWidth +
            root.workspaceButtonWidth - root.activeWorkspaceMargin * 2
        readonly property real indicatorThick:
            root.workspaceButtonWidth - root.activeWorkspaceMargin * 2

        x:             root.vertical ? 0 : indicatorPos
        y:             root.vertical ? indicatorPos : 0
        implicitWidth:  root.vertical ? indicatorThick : indicatorLen
        implicitHeight: root.vertical ? indicatorLen  : indicatorThick
    }

    // ── z:3 — Workspace buttons (icon / dot / number) ─────────────────────
    Grid {
        z: 3
        anchors.centerIn: parent
        rowSpacing: 0
        columnSpacing: 0
        columns: root.vertical ? 1 : root.workspacesShown
        rows:    root.vertical ? root.workspacesShown : 1

        Repeater {
            model: root.workspacesShown

            Item {
                id: wsButton
                required property int index

                readonly property int workspaceValue:
                    root.workspaceGroup * root.workspacesShown + index + 1
                readonly property bool isActive:
                    root.effectiveActiveWorkspaceId === workspaceValue
                readonly property bool isOccupied:
                    root.workspaceOccupied[index] ?? false

                implicitWidth:  root.workspaceButtonWidth
                implicitHeight: root.workspaceButtonWidth

                MouseArea {
                    id: wsMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onPressed: Hyprland.dispatch(`workspace ${wsButton.workspaceValue}`)
                }

                // M3 state layer (hover/press feedback)
                Rectangle {
                    anchors.fill: parent
                    radius: root.workspaceButtonWidth / 2
                    color: Colors.m3onSurface
                    opacity: wsMouseArea.pressed ? 0.12 :
                             wsMouseArea.containsMouse ? 0.08 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic }
                    }
                }

                Item {
                    id: wsBackground
                    anchors.fill: parent

                    property var biggestWindow:
                        WorkspaceAppData.biggestWindowForWorkspace(wsButton.workspaceValue)
                    property string iconSource:
                        Quickshell.iconPath(
                            WorkspaceIconSearch.guessIcon(biggestWindow?.class ?? ""),
                            "image-missing")

                    // Number text
                    Text {
                        anchors.centerIn: parent
                        visible: opacity > 0
                        opacity: root.showNumbers
                            || (Config.workspaceAlwaysShowNumbers
                                && (!Config.workspaceShowAppIcons || !wsBackground.biggestWindow || root.showNumbers))
                            ? 1 : 0
                        z: 3

                        text: wsButton.workspaceValue
                        font.pixelSize: text.toString().length > 1 ? 13 : 15
                        font.family: Config.fontFamily
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: wsButton.isActive ? Colors.m3onPrimary :
                               wsButton.isOccupied ? Colors.m3onSecondaryContainer : Colors.m3onSurfaceInactive

                        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
                        Behavior on color   { ColorAnimation   { duration: M3Easing.effectsDuration } }
                    }

                    // Dot (shown when no icon and no number)
                    Rectangle {
                        id: wsDot
                        anchors.centerIn: parent
                        visible: opacity > 0
                        opacity: (Config.workspaceAlwaysShowNumbers
                            || root.showNumbers
                            || (Config.workspaceShowAppIcons && wsBackground.biggestWindow)
                            ) ? 0 : 1
                        width:  root.workspaceButtonWidth * 0.18
                        height: width
                        radius: width / 2
                        color: wsButton.isActive ? Colors.m3onPrimary :
                               wsButton.isOccupied ? Colors.m3onSecondaryContainer : Colors.m3onSurfaceInactive

                        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
                        Behavior on color   { ColorAnimation   { duration: M3Easing.effectsDuration } }
                    }

                    // App icon
                    Item {
                        anchors.centerIn: parent
                        width:  root.workspaceButtonWidth
                        height: root.workspaceButtonWidth
                        visible: opacity > 0
                        opacity: !Config.workspaceShowAppIcons ? 0 :
                                 (wsBackground.biggestWindow && !root.showNumbers && Config.workspaceShowAppIcons) ?
                                 1 : wsBackground.biggestWindow ? 1 : 0

                        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }

                        IconImage {
                            id: appIcon
                            anchors.bottom: parent.bottom
                            anchors.right: parent.right
                            anchors.bottomMargin: (!root.showNumbers && Config.workspaceShowAppIcons) ?
                                (root.workspaceButtonWidth - root.workspaceIconSize) / 2 : root.workspaceIconMarginShrinked
                            anchors.rightMargin: (!root.showNumbers && Config.workspaceShowAppIcons) ?
                                (root.workspaceButtonWidth - root.workspaceIconSize) / 2 : root.workspaceIconMarginShrinked
                            source: wsBackground.iconSource
                            implicitSize: (!root.showNumbers && Config.workspaceShowAppIcons) ?
                                root.workspaceIconSize : root.workspaceIconSizeShrinked

                            Behavior on implicitSize { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized } }
                            Behavior on anchors.bottomMargin { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized } }
                            Behavior on anchors.rightMargin { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized } }
                        }

                        // Monochrome overlay (optional)
                        Loader {
                            active: Config.workspaceMonochromeIcons
                            anchors.fill: appIcon

                            sourceComponent: Item {
                                Desaturate {
                                    id: desatIcon
                                    visible: false
                                    anchors.fill: parent
                                    source: appIcon
                                    desaturation: 0.8
                                }
                                ColorOverlay {
                                    anchors.fill: desatIcon
                                    source: desatIcon
                                    property color tintColor: wsButton.isActive ? Colors.m3onPrimary : Colors.m3onSecondaryContainer
                                    color: Qt.rgba(tintColor.r, tintColor.g, tintColor.b, 0.9)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
