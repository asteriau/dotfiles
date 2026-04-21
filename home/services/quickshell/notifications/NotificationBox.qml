// Adapted from illogical-impulse
// (~/.config/quickshell/ii/modules/common/widgets/NotificationItem.qml).
// License: upstream dots-hyprland.
// Stripped: drag-to-dismiss, urgency-based color mixing, Appearance/Translation.

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.utils
import qs.components

WrapperMouseArea {
    id: root

    acceptedButtons: Qt.AllButtons
    hoverEnabled: true

    property Notification n
    property var notificationObject: n
    property bool expanded: true
    property bool onlyNotification: false
    property real fontSize: 14
    property real padding: onlyNotification ? 0 : 10
    property real summaryElideRatio: 0.85

    // Colors (M3-ish dark, derived from my palette).
    readonly property color colLayer3: Qt.rgba(0.156, 0.156, 0.156, 0.94)
    readonly property color colLayer4: Qt.rgba(1, 1, 1, 0.08)
    readonly property color colLayer4Hover: Qt.rgba(1, 1, 1, 0.14)
    readonly property color colLayer4Active: Qt.rgba(1, 1, 1, 0.2)
    readonly property color colOnLayer3: Colors.foreground
    readonly property color colSubtext: Qt.rgba(1, 1, 1, 0.68)
    readonly property color colOnSurface: Colors.foreground

    readonly property real roundingSmall: 16
    readonly property real roundingMedium: 20

    onClicked: mouse => {
        if (mouse.button == Qt.LeftButton) {
            const acts = (n?.actions ?? []).filter(a => a.identifier === "default");
            if (acts.length > 0)
                acts[0].invoke();
        } else if (mouse.button == Qt.RightButton) {
            NotificationState.notifDismissByNotif(n);
        } else if (mouse.button == Qt.MiddleButton) {
            NotificationState.dismissAll();
        }
    }

    function filteredActions() {
        return (n?.actions ?? []).filter(a => a.identifier !== "default");
    }

    implicitHeight: background.implicitHeight
    implicitWidth: Config.notificationWidth

    // Inline M3 outlined action button.
    component ActionButton: Rectangle {
        id: btn
        property string buttonText: ""
        property string iconGlyph: ""
        signal clicked

        implicitHeight: 34
        implicitWidth: iconGlyph !== "" ? 48 : Math.max(64, label.implicitWidth + 28)
        radius: 17
        color: btnMouse.pressed ? root.colLayer4Active : btnMouse.containsMouse ? root.colLayer4Hover : root.colLayer4
        antialiasing: true

        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }

        Text {
            id: label
            anchors.centerIn: parent
            visible: btn.iconGlyph === ""
            text: btn.buttonText
            font.family: "Google Sans Flex"
            font.pixelSize: 13
            font.weight: Font.Medium
            color: root.colOnSurface
        }

        Text {
            anchors.centerIn: parent
            visible: btn.iconGlyph !== ""
            text: btn.iconGlyph
            font.family: "Material Symbols Rounded"
            font.pixelSize: 18
            color: root.colOnSurface
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.clicked()
        }
    }

    Rectangle {
        id: background

        anchors.left: parent.left
        width: parent.width
        radius: root.roundingSmall
        color: root.colLayer3
        border.color: Qt.rgba(1, 1, 1, 0.06)
        border.width: 1
        antialiasing: true

        implicitHeight: root.expanded ? (contentColumn.implicitHeight + root.padding * 2) : summaryRow.implicitHeight + root.padding * 2

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: contentColumn

            anchors.fill: parent
            anchors.margins: root.padding
            spacing: 6

            RowLayout {
                id: summaryRow
                Layout.fillWidth: true
                spacing: 12

                // App / image icon (circular), 38px like ii.
                Rectangle {
                    id: notificationIcon
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: 1
                    implicitWidth: 38
                    implicitHeight: 38
                    radius: 19
                    color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.22)
                    antialiasing: true

                    readonly property string image: root.n?.image ?? ""
                    readonly property string appIcon: root.n?.appIcon ?? ""

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        source: notificationIcon.image ? Utils.getImage(notificationIcon.image) : ""
                        visible: notificationIcon.image !== ""
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true
                        asynchronous: true
                    }

                    IconImage {
                        anchors.centerIn: parent
                        implicitSize: 24
                        source: notificationIcon.appIcon ? Utils.getImage(notificationIcon.appIcon) : ""
                        visible: notificationIcon.image === "" && notificationIcon.appIcon !== ""
                        asynchronous: true
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "notifications"
                        font.family: "Material Symbols Rounded"
                        font.pixelSize: 20
                        color: Colors.accent
                        visible: notificationIcon.image === "" && notificationIcon.appIcon === ""
                    }

                    Rectangle {
                        visible: notificationIcon.image !== "" && notificationIcon.appIcon !== ""
                        width: 16
                        height: 16
                        radius: 8
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.rightMargin: -2
                        anchors.bottomMargin: -2
                        color: root.colLayer3

                        IconImage {
                            anchors.fill: parent
                            anchors.margins: 2
                            source: notificationIcon.appIcon ? Utils.getImage(notificationIcon.appIcon) : ""
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: root.n?.appName ?? ""
                        color: root.colSubtext
                        font.family: "Google Sans Flex"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        font.letterSpacing: 0.3
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        visible: text.length > 0
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.n?.summary ?? ""
                        color: root.colOnLayer3
                        font.family: "Google Sans Flex"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.Wrap
                    }
                }
            }

            Text {
                id: notificationBodyText
                Layout.fillWidth: true
                Layout.leftMargin: 38 + 12
                Layout.topMargin: -4
                text: root.n?.body ?? ""
                color: root.colSubtext
                font.family: "Google Sans Flex"
                font.pixelSize: 13
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: root.expanded ? 6 : 2
                visible: text.length > 0
            }

            RowLayout {
                id: actionRowLayout
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 6

                ActionButton {
                    iconGlyph: "close"
                    onClicked: NotificationState.notifCloseByNotif(root.n)
                }

                Repeater {
                    model: root.filteredActions()

                    ActionButton {
                        required property NotificationAction modelData
                        Layout.fillWidth: true
                        buttonText: modelData?.text ?? ""
                        onClicked: modelData?.invoke()
                    }
                }

                ActionButton {
                    id: copyBtn
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
