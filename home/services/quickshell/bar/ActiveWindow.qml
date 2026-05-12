import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
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

    readonly property int hPadding: 14
    readonly property int iconSize: 18
    readonly property int iconGap: 8
    readonly property int maxTitleChars: 32

    visible: !Config.bar.vertical

    // Width-only measurer for the current title; drives the container width.
    TextMetrics {
        id: titleMetrics
        text: root.currentTitle
        font.pixelSize: Appearance.typography.small
        font.family: Config.typography.family
    }
    FontMetrics {
        id: titleFm
        font.pixelSize: Appearance.typography.small
        font.family: Config.typography.family
    }
    readonly property int maxTextWidth: Math.round(titleFm.averageCharacterWidth * maxTitleChars)
    // +2px slack so we don't sit a subpixel under the eliding threshold.
    readonly property int contentTextWidth: Math.min(Math.ceil(titleMetrics.tightBoundingRect.width) + 2, maxTextWidth)

    implicitWidth: currentTitle.length > 0
        ? contentTextWidth + iconSize + iconGap + hPadding * 2
        : 0
    implicitHeight: Appearance.bar.height - Appearance.layout.gapSm * 2

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.motion.duration.spatial
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.motion.easing.emphasized
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Appearance.layout.radiusContainer
        color: Appearance.colors.surfaceContainerLow
        opacity: root.currentTitle.length > 0 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
    }

    // A/B slots — toggled on window change so icon + title crossfade atomically.
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

    RowLayout {
        anchors.centerIn: parent
        spacing: root.iconGap
        opacity: root._aActive ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }

        IconImage {
            visible: root._a.appId.length > 0
            implicitSize: root.iconSize
            mipmap: true
            source: visible ? Quickshell.iconPath(
                WorkspaceIconSearch.guessIcon(root._a.appId), "image-missing") : ""
        }

        StyledText {
            Layout.maximumWidth: root.width - root.hPadding * 2 - root.iconSize - root.iconGap
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Appearance.typography.small
            color: Appearance.colors.foreground
            elide: Text.ElideRight
            text: root._a.title
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: root.iconGap
        opacity: root._aActive ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }

        IconImage {
            visible: root._b.appId.length > 0
            implicitSize: root.iconSize
            mipmap: true
            source: visible ? Quickshell.iconPath(
                WorkspaceIconSearch.guessIcon(root._b.appId), "image-missing") : ""
        }

        StyledText {
            Layout.maximumWidth: root.width - root.hPadding * 2 - root.iconSize - root.iconGap
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Appearance.typography.small
            color: Appearance.colors.foreground
            elide: Text.ElideRight
            text: root._b.title
        }
    }
}
