// Expand-on-demand actions row: close + notification-provided actions + copy.
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property var notificationRef: null
    property real progress: 0

    readonly property var actions: (notificationRef?.actions ?? []).filter(a => a.identifier !== "default")

    signal dismiss

    Layout.fillWidth: true
    Layout.preferredHeight: (actionsRow.implicitHeight + 6) * progress
    implicitHeight: actionsRow.implicitHeight + 6
    clip: true

    // Button styled like the expand pill. Kept local since it's a tiny form
    // unique to notification actions (rectangle + text OR icon, animated color).
    component ActionButton: Rectangle {
        id: abtn
        property string buttonText: ""
        property string iconGlyph: ""
        signal clicked

        implicitHeight: 32
        radius: height / 2
        color: abtnMouse.pressed        ? Appearance.colors.pressedStrong
             : abtnMouse.containsMouse  ? Appearance.colors.hoverStrongest
             :                            Appearance.colors.hover
        antialiasing: true

        Behavior on color {
            ColorAnimation { duration: Appearance.motion.duration.short2 }
        }

        StyledText {
            anchors.centerIn: parent
            visible: abtn.iconGlyph === ""
            text: abtn.buttonText
            color: Appearance.colors.foreground
            font.pixelSize: Appearance.typography.small
            font.weight: Font.Medium
            elide: Text.ElideRight
            width: parent.width - 18
            horizontalAlignment: Text.AlignHCenter
        }

        MaterialIcon {
            anchors.centerIn: parent
            visible: abtn.iconGlyph !== ""
            text: abtn.iconGlyph
            color: Appearance.colors.foreground
            pixelSize: Appearance.typography.large
        }

        MouseArea {
            id: abtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: abtn.clicked()
        }
    }

    RowLayout {
        id: actionsRow
        anchors.left: parent.left
        anchors.right: parent.right
        y: 6 * root.progress
        spacing: 6
        opacity: root.progress
        scale: 0.92 + (0.08 * root.progress)
        transformOrigin: Item.Top
        enabled: root.progress > 0

        ActionButton {
            Layout.fillWidth: true
            iconGlyph: "close"
            onClicked: root.dismiss()
        }

        Repeater {
            model: root.actions

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
                Quickshell.clipboardText = root.notificationRef?.body ?? "";
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
