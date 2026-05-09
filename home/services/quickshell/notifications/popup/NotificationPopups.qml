pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.notifications
import qs.utils
import qs.utils.state

// Top-level floating notification popups. Mirrors bar position so popups
// land in the screen corner opposite the bar (so they never overlap it).
// Critical urgency stays sticky; Do Not Disturb suppresses everything.
Scope {
    id: scope

    readonly property bool dnd: Config.doNotDisturb
    readonly property var notifs: scope.dnd ? [] : NotificationState.popupNotifs

    // Mirrors bar position. bar=left → top-right; bar=right → top-left;
    // bar=top → top-right (offset below bar); bar=bottom → bottom-right
    // (offset above bar).
    readonly property string resolved: {
        switch (Config.bar.position) {
            case "right":  return "top-left";
            case "bottom": return "bottom-right";
            default:       return "top-right";
        }
    }

    readonly property bool anchorTop:    resolved.startsWith("top")
    readonly property bool anchorBottom: resolved.startsWith("bottom")
    readonly property bool anchorRight:  resolved.endsWith("right")
    readonly property bool anchorLeft:   resolved.endsWith("left")

    readonly property int marginTop:    anchorTop    && Config.bar.position === "top"    ? Config.bar.height + 8 : (anchorTop    ? 12 : 0)
    readonly property int marginBottom: anchorBottom && Config.bar.position === "bottom" ? Config.bar.height + 8 : (anchorBottom ? 12 : 0)
    readonly property int marginRight:  anchorRight  && Config.bar.position === "right"  ? Config.bar.width + 8  : (anchorRight  ? 12 : 0)
    readonly property int marginLeft:   anchorLeft   && Config.bar.position === "left"   ? Config.bar.width + 8  : (anchorLeft   ? 12 : 0)

    PanelWindow {
        id: win
        screen: UiState.preferredMonitor
        visible: scope.notifs.length > 0

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "quickshell:notification-popup"
        color: "transparent"
        mask: Region { item: list }

        anchors {
            top:    scope.anchorTop
            bottom: scope.anchorBottom
            left:   scope.anchorLeft
            right:  scope.anchorRight
        }
        margins {
            top:    scope.marginTop
            bottom: scope.marginBottom
            left:   scope.marginLeft
            right:  scope.marginRight
        }

        implicitWidth: Config.notifications.width + 24
        implicitHeight: list.contentHeight + 24

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 12
            interactive: false
            spacing: 8
            verticalLayoutDirection: scope.anchorBottom ? ListView.BottomToTop : ListView.TopToBottom

            model: scope.notifs

            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1; duration: M3Easing.spatialDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasizedDecel }
                NumberAnimation { property: "scale";   from: 0.9; to: 1; duration: M3Easing.spatialDuration; easing.type: Easing.BezierSpline; easing.bezierCurve: M3Easing.emphasizedDecel }
            }
            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: M3Easing.durationMedium2; easing.bezierCurve: M3Easing.emphasized }
            }

            delegate: NotificationPopupItem {
                required property var modelData
                width: Config.notifications.width
                n: modelData
            }
        }
    }
}
