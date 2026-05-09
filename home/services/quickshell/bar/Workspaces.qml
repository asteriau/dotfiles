pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.utils
import qs.bar.workspaces

// Orchestrator for the bar's workspaces widget. Owns occupancy tracking,
// scroll-to-switch, and the layered composition (capsule → orbs → active
// shape → buttons). The per-slot visuals live in bar/workspaces/.
//
// NOTE: This file lives at bar/Workspaces.qml (not bar/workspaces/Workspaces.qml)
// so that Bar.qml / BarHorizontal.qml can keep using `Workspaces {}` without an
// extra import. The delegates underneath live in bar/workspaces/ and are imported
// via `qs.bar.workspaces` below.
Item {
    id: root

    property bool vertical: Config.bar.vertical

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property int effectiveActiveWorkspaceId: monitor?.activeWorkspace?.id ?? 1
    readonly property int workspacesShown: Config.workspaces.shown
    readonly property int workspaceGroup: Math.floor((effectiveActiveWorkspaceId - 1) / workspacesShown)
    readonly property int workspaceIndexInGroup: (effectiveActiveWorkspaceId - 1) % workspacesShown

    property list<bool> workspaceOccupied: []

    readonly property int  workspaceButtonWidth: 26
    readonly property real activeWorkspaceMargin: 2
    readonly property int  verticalPadding: 4

    readonly property bool showNumbers: UiState.showWorkspaceNumbers

    implicitWidth:  vertical ? Config.bar.width : (workspaceButtonWidth * workspacesShown)
    implicitHeight: vertical ? (workspaceButtonWidth * workspacesShown + verticalPadding * 2) : Config.bar.height

    // ── Occupancy tracking ────────────────────────────────────────────────
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

    // Scroll to switch workspaces.
    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y < 0)
                Hyprland.dispatch("workspace r+1");
            else if (event.angleDelta.y > 0)
                Hyprland.dispatch("workspace r-1");
        }
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
    }

    // z:0 — capsule container.
    Rectangle {
        z: 0
        anchors {
            fill: parent
            topMargin:    root.vertical ? 0 : 4
            bottomMargin: root.vertical ? 0 : 4
            leftMargin:   root.vertical ? 4 : 0
            rightMargin:  root.vertical ? 4 : 0
        }
        radius: Config.layout.radiusMd
        color: Colors.surfaceContainer
    }

    // z:2 — occupied orbs that merge into a continuous pill.
    Grid {
        z: 2
        anchors.centerIn: parent
        rowSpacing: 0
        columnSpacing: 0
        columns: root.vertical ? 1 : root.workspacesShown
        rows:    root.vertical ? root.workspacesShown : 1

        Repeater {
            model: root.workspacesShown

            WorkspaceOrb {
                buttonWidth: root.workspaceButtonWidth
                vertical:    root.vertical
                perGroup:    root.workspacesShown
                activeId:    root.effectiveActiveWorkspaceId
                activeWindowActivated: root.activeWindow?.activated ?? false
                occupied:    root.workspaceOccupied
            }
        }
    }

    // z:3 — active-workspace morphing pill.
    WorkspaceActiveShape {
        z: 3
        indexInGroup:      root.workspaceIndexInGroup
        activeWorkspaceId: root.effectiveActiveWorkspaceId
        buttonWidth:       root.workspaceButtonWidth
        activeMargin:      root.activeWorkspaceMargin
        vertical:          root.vertical
        verticalPadding:   root.verticalPadding
    }

    // z:4 — per-slot buttons (ring, icon/number, hover).
    Grid {
        z: 4
        anchors.centerIn: parent
        rowSpacing: 0
        columnSpacing: 0
        columns: root.vertical ? 1 : root.workspacesShown
        rows:    root.vertical ? root.workspacesShown : 1

        Repeater {
            model: root.workspacesShown

            WorkspaceButton {
                buttonWidth: root.workspaceButtonWidth
                showNumbers: root.showNumbers
                group:       root.workspaceGroup
                perGroup:    root.workspacesShown
                activeId:    root.effectiveActiveWorkspaceId
                occupied:    root.workspaceOccupied
            }
        }
    }
}
