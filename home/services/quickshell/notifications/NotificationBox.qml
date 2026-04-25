// Mirrors ii NotificationGroup + NotificationItem (modules/common/widgets).
// License: upstream dots-hyprland.

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.utils

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

    readonly property color colLayer2: Qt.rgba(0x1E / 255, 0x1E / 255, 0x1E / 255, 0.94)
    readonly property color colLayer3: Qt.rgba(0x24 / 255, 0x24 / 255, 0x24 / 255, 0.94)
    readonly property color colLayer3Transparent: Qt.rgba(0x24 / 255, 0x24 / 255, 0x24 / 255, 0.0)
    readonly property color colBorder: Colors.border
    readonly property color colBtnRest: Qt.rgba(1, 1, 1, 0.06)
    readonly property color colBtnHover: Qt.rgba(1, 1, 1, 0.12)
    readonly property color colBtnActive: Qt.rgba(1, 1, 1, 0.18)
    readonly property color colOnLayer: Colors.foreground
    readonly property color colSubtext: Colors.comment
    readonly property color colUrgentTint: Qt.rgba(Colors.red.r, Colors.red.g, Colors.red.b, 0.10)

    readonly property real radiusFull: 999
    readonly property real radiusNormal: 24
    readonly property real radiusSmall: 20

    readonly property real fontSmallest: 10
    readonly property real fontSmaller: 12
    readonly property real fontSmall: 15
    readonly property real fontBody: 13
    readonly property real fontNormal: 16
    readonly property real fontLarger: 17
    readonly property string fontMain: Config.fontFamily

    property string timeString: NotificationUtils.getFriendlyNotifTimeString(n?.time)

    implicitWidth: Config.notificationWidth
    implicitHeight: background.implicitHeight

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

    function filteredActions() {
        return (n?.actions ?? []).filter(a => a.identifier !== "default");
    }

    function invokeDefault() {
        const acts = (n?.actions ?? []).filter(a => a.identifier === "default");
        if (acts.length > 0)
            acts[0].invoke();
    }

    // Chevron-only pill (ii NotificationGroupExpandButton; no count for single notif)
    component ExpandPill: Rectangle {
        id: pill
        signal clicked
        readonly property bool hovered: pillMouse.containsMouse

        implicitHeight: root.fontSmaller + 8
        implicitWidth: Math.max(30, chevron.implicitWidth + 10)
        radius: height / 2
        color: pillMouse.pressed ? root.colBtnActive : pill.hovered ? root.colBtnHover : root.colBtnRest
        antialiasing: true

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Text {
            id: chevron
            anchors.centerIn: parent
            text: "keyboard_arrow_down"
            color: root.colOnLayer
            font.family: "Material Symbols Rounded"
            font.pixelSize: root.fontNormal
            rotation: root.expanded ? 180 : 0

            Behavior on rotation {
                NumberAnimation {
                    duration: M3Easing.durationMedium1
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: M3Easing.emphasized
                }
            }
        }

        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse => {
                mouse.accepted = true;
                pill.clicked();
            }
        }
    }

    // Pill action button (close / custom / copy) — shown when expanded
    component ActionButton: Rectangle {
        id: abtn
        property string buttonText: ""
        property string iconGlyph: ""
        signal clicked

        implicitHeight: 32
        radius: height / 2
        color: abtnMouse.pressed ? root.colBtnActive : abtnMouse.containsMouse ? root.colBtnHover : root.colBtnRest
        antialiasing: true

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Text {
            anchors.centerIn: parent
            visible: abtn.iconGlyph === ""
            text: abtn.buttonText
            color: root.colOnLayer
            font.family: root.fontMain
            font.pixelSize: root.fontSmall
            font.weight: Font.Medium
            elide: Text.ElideRight
            width: parent.width - 18
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.centerIn: parent
            visible: abtn.iconGlyph !== ""
            text: abtn.iconGlyph
            color: root.colOnLayer
            font.family: "Material Symbols Rounded"
            font.pixelSize: root.fontLarger
        }

        MouseArea {
            id: abtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: abtn.clicked()
        }
    }

    Rectangle {
        id: background

        x: 0
        width: parent.width
        color: root.isPopup ? root.colLayer2 : Colors.elevated
        radius: root.isPopup ? root.radiusNormal : root.radiusSmall
        border.width: 1
        border.color: root.colBorder
        antialiasing: true
        clip: true
        opacity: Math.max(0, 1 - Math.abs(x) / (width * 0.9))

        implicitHeight: root.expanded ? (row.implicitHeight + root.padding * 2) : Math.min(root.collapsedMaxHeight, row.implicitHeight + root.padding * 2)

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
                if (mouse.button === Qt.LeftButton) {
                    root.invokeDefault();
                } else if (mouse.button === Qt.RightButton) {
                    root.expanded = !root.expanded;
                } else if (mouse.button === Qt.MiddleButton) {
                    if (root.n)
                        NotificationState.notifCloseByNotif(root.n);
                }
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
            onFinished: {
                if (root.n)
                    NotificationState.notifCloseByNotif(root.n);
            }
        }

        RowLayout {
            id: row
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: root.padding
            spacing: 10

            NotificationAppIcon {
                id: notifIcon
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

                // Top row: summary/appName + timestamp pill
                Item {
                    id: topRow
                    Layout.fillWidth: true
                    implicitHeight: Math.max(topTextRow.implicitHeight, expandBtn.implicitHeight)

                    RowLayout {
                        id: topTextRow
                        anchors.left: parent.left
                        anchors.right: expandBtn.left
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 5

                        Text {
                            id: summaryText
                            Layout.fillWidth: true
                            text: root.n?.summary ?? ""
                            color: root.colOnLayer
                            font.family: root.fontMain
                            font.pixelSize: root.fontSmall
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            Layout.rightMargin: 6
                            text: root.timeString
                            color: root.colSubtext
                            font.family: root.fontMain
                            font.pixelSize: root.fontSmaller
                        }
                    }

                    ExpandPill {
                        id: expandBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: root.expanded = !root.expanded
                    }
                }

                // Body / content — two-line preview when collapsed, full when expanded
                Text {
                    id: bodyText
                    Layout.fillWidth: true
                    text: root.expanded ? NotificationUtils.processNotificationBody(root.n?.body ?? "", root.n?.appName ?? "") : (root.n?.body ?? "")
                    color: root.colSubtext
                    font.family: root.fontMain
                    font.pixelSize: root.fontBody
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: root.expanded ? 100 : 2
                    textFormat: root.expanded ? Text.RichText : Text.PlainText
                    verticalAlignment: Text.AlignTop
                    visible: text.length > 0
                }

                // Actions row (expanded only)
                Item {
                    id: actionsWrapper
                    Layout.fillWidth: true
                    Layout.preferredHeight: (actionsRow.implicitHeight + 6) * root.actionsProgress
                    implicitHeight: actionsRow.implicitHeight + 6
                    clip: true

                    RowLayout {
                        id: actionsRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        y: 6 * root.actionsProgress
                        spacing: 6
                        opacity: root.actionsProgress
                        scale: 0.92 + (0.08 * root.actionsProgress)
                        transformOrigin: Item.Top
                        enabled: root.actionsProgress > 0

                        ActionButton {
                            Layout.fillWidth: true
                            iconGlyph: "close"
                            onClicked: {
                                if (root.n)
                                    NotificationState.notifCloseByNotif(root.n);
                            }
                        }

                        Repeater {
                            model: root.filteredActions()

                            ActionButton {
                                required property var modelData
                                Layout.fillWidth: true
                                buttonText: modelData?.text ?? ""
                                onClicked: modelData?.invoke()
                            }
                        }

                        ActionButton {
                            id: copyBtn
                            Layout.fillWidth: true
                            property string copyState: "content_copy"
                            iconGlyph: copyState
                            onClicked: {
                                Quickshell.clipboardText = root.n?.body ?? "";
                                copyState = "inventory";
                                copyResetTimer.restart();
                            }
                            Timer {
                                id: copyResetTimer
                                interval: 1500
                                onTriggered: copyBtn.copyState = "content_copy"
                            }
                        }
                    }
                }
            }
        }
    }
}
