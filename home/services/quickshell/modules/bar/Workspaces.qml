pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.modules.bar.workspaces

Item {
    id: root

    property bool vertical: Config.bar.vertical
    property string cluster: "solo"

    readonly property bool _roundStart: cluster === "start" || cluster === "solo"
    readonly property bool _roundEnd:   cluster === "end"   || cluster === "solo"
    readonly property bool _roundTL: vertical ? _roundStart : _roundStart
    readonly property bool _roundTR: vertical ? _roundStart : _roundEnd
    readonly property bool _roundBL: vertical ? _roundEnd   : _roundStart
    readonly property bool _roundBR: vertical ? _roundEnd   : _roundEnd

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

    implicitWidth:  vertical ? Appearance.bar.width : (workspaceButtonWidth * workspacesShown)
    implicitHeight: vertical ? (workspaceButtonWidth * workspacesShown + verticalPadding * 2) : Appearance.bar.height

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

    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y < 0)
                HyprlandActions.nextWorkspace();
            else if (event.angleDelta.y > 0)
                HyprlandActions.prevWorkspace();
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
        radius: Appearance.layout.radiusContainer
        topLeftRadius:     root._roundTL ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        topRightRadius:    root._roundTR ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        bottomLeftRadius:  root._roundBL ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        bottomRightRadius: root._roundBR ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        color: Appearance.colors.surfaceContainerLow
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
