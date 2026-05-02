import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.components.text
import qs.utils

Item {
    id: root

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property bool focusedHere: activeWindow?.activated ?? false
    readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? 1
    readonly property var biggestWin: WorkspaceAppData.biggestWindowForWorkspace(activeWorkspaceId)

    readonly property string currentAppId: focusedHere && activeWindow && biggestWin
        ? activeWindow.appId : (biggestWin?.class ?? "")
    readonly property string currentTitle: focusedHere && activeWindow && biggestWin
        ? activeWindow.title : (biggestWin?.title ?? "")

    property int maxTitleWidth: 240

    visible: !Config.bar.vertical

    implicitWidth:  maxTitleWidth
    implicitHeight: colA.implicitHeight

    // A/B slots — toggled on window change so both lines crossfade atomically.
    property var _a: ({ appId: "", title: "" })
    property var _b: ({ appId: "", title: "" })
    property bool _aActive: true

    function _update() {
        const next = { appId: root.currentAppId, title: root.currentTitle }
        const current = _aActive ? _a : _b
        if (current.appId === next.appId && current.title === next.title) return
        if (_aActive) { _b = next; _aActive = false }
        else          { _a = next; _aActive = true  }
    }

    onCurrentAppIdChanged: Qt.callLater(_update)
    onCurrentTitleChanged: Qt.callLater(_update)
    Component.onCompleted: { _a = { appId: currentAppId, title: currentTitle } }

    ColumnLayout {
        id: colA
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        spacing: -4
        opacity: root._aActive ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }

        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Config.typography.smallest
            color: Colors.m3onSurfaceInactive
            elide: Text.ElideRight
            text: root._a.appId
        }
        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Config.typography.small
            color: Colors.foreground
            elide: Text.ElideRight
            text: root._a.title
        }
    }

    ColumnLayout {
        id: colB
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        spacing: -4
        opacity: root._aActive ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }

        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Config.typography.smallest
            color: Colors.m3onSurfaceInactive
            elide: Text.ElideRight
            text: root._b.appId
        }
        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Config.typography.small
            color: Colors.foreground
            elide: Text.ElideRight
            text: root._b.title
        }
    }
}
