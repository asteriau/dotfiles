// Notification card: orchestrator for header/body/actions with drag-to-dismiss
// and expand animation. Inspired by ii's NotificationGroup/NotificationItem.

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.utils
import qs.utils.state

Item {
    id: root

    property var n
    property var notificationObject: n
    property bool isPopup: false
    property bool expanded: false
    property real actionsProgress: 0
    property bool onlyNotification: true
    property real padding: 10
    property real collapsedMaxHeight: 80

    property string timeString: NotificationUtils.getFriendlyNotifTimeString(n?.time)

    implicitWidth: Config.notifications.width
    implicitHeight: background.implicitHeight

    // Popup appear animation.
    NumberAnimation on opacity {
        from: 0
        to: 1
        duration: M3Easing.spatialDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: M3Easing.emphasizedDecel
        running: root.isPopup
    }
    NumberAnimation on scale {
        from: 0.90
        to: 1
        duration: M3Easing.spatialDuration
        easing.type: Easing.BezierSpline
        easing.bezierCurve: M3Easing.emphasizedDecel
        running: root.isPopup
    }

    Behavior on actionsProgress {
        NumberAnimation {
            duration: M3Easing.durationMedium2
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.expanded ? M3Easing.emphasizedDecel : M3Easing.emphasizedAccel
        }
    }

    Component.onCompleted: actionsProgress = expanded ? 1 : 0
    onExpandedChanged: actionsProgress = expanded ? 1 : 0

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.timeString = NotificationUtils.getFriendlyNotifTimeString(root.n?.time)
    }

    function invokeDefault() {
        const acts = (n?.actions ?? []).filter(a => a.identifier === "default");
        if (acts.length > 0)
            acts[0].invoke();
    }

    function closeSelf() {
        if (root.n)
            NotificationState.notifCloseByNotif(root.n);
    }

    Rectangle {
        id: background

        x: 0
        width: parent.width
        color: root.isPopup ? Colors.popupBackground : Colors.elevated
        radius: root.isPopup ? Config.layout.notificationRadius : Config.layout.notificationCollapsedR
        antialiasing: true
        clip: true
        opacity: Math.max(0, 1 - Math.abs(x) / (width * 0.9))

        implicitHeight: root.expanded
            ? (row.implicitHeight + root.padding * 2)
            : Math.min(root.collapsedMaxHeight, row.implicitHeight + root.padding * 2)

        Behavior on implicitHeight {
            NumberAnimation {
                duration: M3Easing.durationMedium2
                easing.type: Easing.OutCubic
            }
        }

        Behavior on x {
            enabled: !dragHandler.active
            NumberAnimation {
                duration: M3Easing.durationMedium1
                easing.type: Easing.BezierSpline
                easing.bezierCurve: M3Easing.emphasizedDecel
            }
        }

        MouseArea {
            id: rootMouse
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: true
            onClicked: mouse => {
                if (mouse.button === Qt.LeftButton)
                    root.invokeDefault();
                else if (mouse.button === Qt.RightButton)
                    root.expanded = !root.expanded;
                else if (mouse.button === Qt.MiddleButton)
                    root.closeSelf();
            }
        }

        DragHandler {
            id: dragHandler
            target: background
            yAxis.enabled: false
            xAxis.enabled: true
            enabled: !root.expanded

            onActiveChanged: {
                if (!active) {
                    const threshold = 70;
                    if (Math.abs(background.x) > threshold) {
                        dismissAnim.to = background.x > 0 ? background.width + 40 : -(background.width + 40);
                        dismissAnim.start();
                    } else {
                        background.x = 0;
                    }
                }
            }
        }

        NumberAnimation {
            id: dismissAnim
            target: background
            property: "x"
            duration: M3Easing.durationMedium1
            easing.type: Easing.BezierSpline
            easing.bezierCurve: M3Easing.emphasizedAccel
            onFinished: root.closeSelf()
        }

        RowLayout {
            id: row
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: root.padding
            spacing: 10

            NotificationAppIcon {
                Layout.alignment: Qt.AlignTop
                implicitSize: 38
                image: root.n?.image ?? ""
                appIcon: root.n?.appIcon ?? ""
                summary: root.n?.summary ?? ""
                urgency: root.n?.urgency ?? NotificationUrgency.Normal
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 4

                NotificationHeader {
                    Layout.fillWidth: true
                    summary: root.n?.summary ?? ""
                    timeString: root.timeString
                    expanded: root.expanded
                    count: root.n?.count ?? 1
                    onToggleExpanded: root.expanded = !root.expanded
                }

                NotificationBody {
                    notificationRef: root.n
                    expanded: root.expanded
                }

                NotificationActions {
                    notificationRef: root.n
                    progress: root.actionsProgress
                    onDismiss: root.closeSelf()
                }
            }
        }
    }
}
