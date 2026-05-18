import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

Item {
    id: root

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(QsWindow.window?.screen)
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel
    readonly property bool focusedHere: activeWindow?.activated ?? false
    readonly property int activeWorkspaceId: monitor?.activeWorkspace?.id ?? 1
    readonly property var biggestWin: WindowList.biggestWindowForWorkspace(activeWorkspaceId)

    readonly property string currentAppId: focusedHere && activeWindow && biggestWin ? activeWindow.appId : (
                                                                                           biggestWin?.class
                                                                                           ?? "")
    readonly property string currentTitle: focusedHere && activeWindow && biggestWin ? activeWindow.title : (
                                                                                           biggestWin?.title
                                                                                           ?? "")

    readonly property int hPadding: 14
    readonly property int iconSize: 18
    readonly property int iconGap: 8
    readonly property int maxTitleChars: 32

    // The only thing the box width and content read from. Reassigned (never
    // mutated in place) by commit() so dependent bindings re-evaluate.
    property var committed: ({
                                 appId: "",
                                 title: ""
                             })

    // Title double-buffer: flips on every commit so the two StyledTexts crossfade.
    property string textA: ""
    property string textB: ""
    property bool textActive: true

    // Icon double-buffer: flips only when the app changes, so a title-only
    // change (tab/file switch within one app) leaves the icon perfectly still.
    property string iconA: ""
    property string iconB: ""
    property bool iconActive: true

    // Suppresses animation on first paint; commits after startup animate.
    property bool ready: false

    visible: !Config.bar.vertical
    clip: true

    // One animation spec for every morphing property in this file. Local on
    // purpose: no new global token, no edits to shared Motion.* consumers.
    component MorphAnim: NumberAnimation {
        duration: Appearance.motion.duration.spatial
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Appearance.motion.easing.emphasized
    }

    function commit() {
        const nextAppId = root.currentAppId;
        const nextTitle = root.currentTitle;
        if (root.committed.appId === nextAppId && root.committed.title === nextTitle)
            return;

        const appChanged = root.committed.appId !== nextAppId;

        if (root.textActive) {
            root.textB = nextTitle;
            root.textActive = false;
        } else {
            root.textA = nextTitle;
            root.textActive = true;
        }

        if (appChanged) {
            if (root.iconActive) {
                root.iconB = nextAppId;
                root.iconActive = false;
            } else {
                root.iconA = nextAppId;
                root.iconActive = true;
            }
        }

        root.committed = {
            appId: nextAppId,
            title: nextTitle
        };
    }

    onCurrentAppIdChanged: commitTimer.restart()
    onCurrentTitleChanged: commitTimer.restart()

    Component.onCompleted: {
        root.committed = {
            appId: root.currentAppId,
            title: root.currentTitle
        };
        root.textA = root.currentTitle;
        root.iconA = root.currentAppId;
        root.ready = true;
    }

    // Coalesces title-streaming apps and rapid focus flicking into one settled
    // commit; only the final state animates.
    Timer {
        id: commitTimer
        interval: Appearance.motion.duration.instant
        onTriggered: root.commit()
    }

    TextMetrics {
        id: titleMetrics
        text: root.committed.title
        font.pixelSize: Appearance.typography.small
        font.family: Config.typography.family
    }
    FontMetrics {
        id: titleFm
        font.pixelSize: Appearance.typography.small
        font.family: Config.typography.family
    }

    readonly property int maxTextWidth: Math.round(titleFm.averageCharacterWidth * maxTitleChars)
    readonly property int contentTextWidth: Math.min(Math.ceil(titleMetrics.advanceWidth), maxTextWidth)

    implicitWidth: root.committed.title.length > 0 ? contentTextWidth + iconSize + iconGap + hPadding * 2 : 0
    implicitHeight: Appearance.bar.height - Appearance.layout.gapSm * 2

    Behavior on implicitWidth {
        enabled: root.ready
        MorphAnim {}
    }

    Rectangle {
        anchors.fill: parent
        radius: Appearance.layout.radiusContainer
        color: Appearance.colors.surfaceContainerLow
        opacity: root.committed.title.length > 0 ? 1 : 0

        Behavior on opacity {
            enabled: root.ready
            MorphAnim {}
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: root.iconGap
        opacity: root.committed.title.length > 0 ? 1 : 0

        Behavior on opacity {
            enabled: root.ready
            MorphAnim {}
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: root.iconSize
            implicitHeight: root.iconSize

            IconImage {
                anchors.fill: parent
                mipmap: true
                opacity: root.iconActive ? 1 : 0
                source: root.iconA.length > 0 ? Quickshell.iconPath(WorkspaceIcons.guessIcon(root.iconA), "image-missing") :
                                                ""

                Behavior on opacity {
                    enabled: root.ready
                    MorphAnim {}
                }
            }
            IconImage {
                anchors.fill: parent
                mipmap: true
                opacity: root.iconActive ? 0 : 1
                source: root.iconB.length > 0 ? Quickshell.iconPath(WorkspaceIcons.guessIcon(root.iconB), "image-missing") :
                                                ""

                Behavior on opacity {
                    enabled: root.ready
                    MorphAnim {}
                }
            }
        }

        Item {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Math.max(0, root.width - root.hPadding * 2 - root.iconSize - root.iconGap)
            implicitHeight: titleFm.height

            StyledText {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Appearance.typography.small
                color: Appearance.colors.foreground
                elide: Text.ElideRight
                text: root.textA
                opacity: root.textActive ? 1 : 0

                Behavior on opacity {
                    enabled: root.ready
                    MorphAnim {}
                }
            }
            StyledText {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: Appearance.typography.small
                color: Appearance.colors.foreground
                elide: Text.ElideRight
                text: root.textB
                opacity: root.textActive ? 0 : 1

                Behavior on opacity {
                    enabled: root.ready
                    MorphAnim {}
                }
            }
        }
    }
}
