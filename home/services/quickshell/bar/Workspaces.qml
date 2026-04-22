pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
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

    // ── Workspace occupancy tracking ──────────────────────────────────────
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

    // ══════════════════════════════════════════════════════════════════════
    // z:0 — Capsule container
    // ══════════════════════════════════════════════════════════════════════
    Rectangle {
        z: 0
        anchors.fill: parent
        radius: 12
        color: Colors.elevated
    }



    // ══════════════════════════════════════════════════════════════════════
    // z:2 — Occupied workspace orb tiles (organic merging shapes)
    // ══════════════════════════════════════════════════════════════════════
    Grid {
        z: 2
        anchors.centerIn: parent
        rowSpacing: 0
        columnSpacing: 0
        columns: root.vertical ? 1 : root.workspacesShown
        rows:    root.vertical ? root.workspacesShown : 1

        Repeater {
            model: root.workspacesShown

            Rectangle {
                id: occupiedOrb
                required property int index

                readonly property bool prevOccupied:
                    (index > 0 ? (root.workspaceOccupied[index - 1] ?? false) : false) &&
                    !(!root.activeWindow?.activated && root.effectiveActiveWorkspaceId === index)
                readonly property bool nextOccupied:
                    (index < root.workspacesShown - 1 ? (root.workspaceOccupied[index + 1] ?? false) : false) &&
                    !(!root.activeWindow?.activated && root.effectiveActiveWorkspaceId === index + 2)

                readonly property real rFull: root.workspaceButtonWidth / 2

                implicitWidth:  root.workspaceButtonWidth
                implicitHeight: root.workspaceButtonWidth

                topLeftRadius:     root.vertical ? (prevOccupied ? 0 : rFull) : (prevOccupied ? 0 : rFull)
                bottomLeftRadius:  root.vertical ? (nextOccupied ? 0 : rFull) : (prevOccupied ? 0 : rFull)
                topRightRadius:    root.vertical ? (prevOccupied ? 0 : rFull) : (nextOccupied ? 0 : rFull)
                bottomRightRadius: root.vertical ? (nextOccupied ? 0 : rFull) : (nextOccupied ? 0 : rFull)

                color: Colors.wsOrbFill

                readonly property bool isOccupiedVisible:
                    (root.workspaceOccupied[index] ?? false) &&
                    !(!root.activeWindow?.activated &&
                      root.effectiveActiveWorkspaceId === index + 1)

                opacity: isOccupiedVisible ? 1 : 0
                
                Behavior on opacity {
                    NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic }
                }
                Behavior on topLeftRadius {
                    NumberAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized }
                }
                Behavior on bottomRightRadius {
                    NumberAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized }
                }
                Behavior on topRightRadius {
                    NumberAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized }
                }
                Behavior on bottomLeftRadius {
                    NumberAnimation { duration: M3Easing.spatialDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasized }
                }

                // Removed inner volume rectangle to preserve smooth continuous pill appearance instead of disconnected squares
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // z:3 — Active workspace pill (morphing material shape)
    // ══════════════════════════════════════════════════════════════════════
    Item {
        z: 3

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

        MaterialShape {
            anchors.fill: parent
            color: Colors.accent

            // Stretchy aspect ratio morphing helps it transition nicely across workspaces 
            // when bounding width/height expands dynamically
            implicitSize: Math.max(parent.width, parent.height)

            property list<var> morphShapes: [
                MaterialShape.Shape.Pill,
                MaterialShape.Shape.Clover4Leaf,
                MaterialShape.Shape.SoftBurst,
                MaterialShape.Shape.Cookie6Sided,
                MaterialShape.Shape.Cookie12Sided,
                MaterialShape.Shape.Ghostish,
                MaterialShape.Shape.Pentagon
            ]

            // Dynamically pick a distinct shape based on current workspace
            shape: morphShapes[((root.effectiveActiveWorkspaceId ?? 1) - 1) % morphShapes.length]

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.8
                shadowColor: Colors.wsActiveGlow
                shadowHorizontalOffset: 0
                shadowVerticalOffset: 2
                blurMax: 32
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // z:4 — Workspace buttons (ring outlines / icons / numbers + hover)
    // ══════════════════════════════════════════════════════════════════════
    Grid {
        z: 4
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

                // Flat luminous hover state (replaces unclipped radial layer)
                Rectangle {
                    anchors.centerIn: parent
                    width: root.workspaceButtonWidth
                    height: width
                    radius: width / 2
                    
                    color: Colors.m3onSurface
                    opacity: wsMouseArea.pressed ? 0.18 :
                             wsMouseArea.containsMouse ? 0.12 : 0

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
                    ShadowText {
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

                    // Flat dot for empty workspaces
                    Rectangle {
                        id: wsDot
                        anchors.centerIn: parent
                        visible: opacity > 0
                        opacity: (Config.workspaceAlwaysShowNumbers
                            || root.showNumbers
                            || (Config.workspaceShowAppIcons && wsBackground.biggestWindow)
                            ) ? 0 : 1
                        width:  root.workspaceButtonWidth * 0.15
                        height: width
                        radius: width / 2
                        color: wsButton.isActive ? Colors.m3onPrimary :
                               wsButton.isOccupied ? Colors.m3onSecondaryContainer : Colors.m3onSurfaceInactive

                        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
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

                        // Subtle scale bounce on active transition
                        scale: wsButton.isActive ? 1.05 : 1.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: M3Easing.spatialDuration
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: M3Easing.emphasized
                            }
                        }

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
