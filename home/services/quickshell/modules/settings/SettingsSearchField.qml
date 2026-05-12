import QtQuick
import QtQuick.Controls
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models

Item {
    id: root

    property alias text: input.text
    property string placeholder: "Search settings"

    signal queryChanged(string q)
    signal submitted
    signal escapePressed
    signal arrowDown
    signal arrowUp

    function focusInput()   { input.forceActiveFocus(); }
    function unfocusInput() { input.focus = false; root.forceActiveFocus(); }
    function clearText()    { input.text = ""; }

    implicitHeight: 48
    implicitWidth: 520

    // Left tonal icon pill — anchored, never reflows
    Item {
        id: iconPill
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        height: 44

        MaterialShape {
            anchors.fill: parent
            color: Appearance.colors.secondaryContainer
            implicitSize: Math.max(width, height)
            shape: input.text === ""
                ? MaterialShape.Shape.Cookie7Sided
                : MaterialShape.Shape.Clover4Leaf

            Behavior on color {
                ColorAnimation { duration: Appearance.motion.duration.medium3; easing.bezierCurve: Appearance.motion.easing.emphasized }
            }
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: input.text === "" ? "search" : "manage_search"
            pixelSize: Appearance.typography.huge
            color: Appearance.colors.m3onSecondaryContainer
        }
    }

    // Field
    Item {
        anchors.left: iconPill.right
        anchors.leftMargin: Appearance.layout.gapMd
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 44

        Rectangle {
            anchors.fill: parent
            radius: 22
            color: input.activeFocus ? Appearance.colors.surfaceContainerHigh : Appearance.colors.surfaceContainer
            Behavior on color { ColorAnimation { duration: Appearance.motion.duration.effects } }
        }

        TextField {
            id: input
            anchors.fill: parent
            leftPadding: 18
            rightPadding: clearChip.visible ? 44 : 18
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.normal
            color: Appearance.colors.foreground
            placeholderText: ""
            selectByMouse: true
            selectionColor: Appearance.colors.accent
            selectedTextColor: Appearance.colors.accentText
            verticalAlignment: TextInput.AlignVCenter
            background: null

            onTextChanged: root.queryChanged(text)
            onAccepted: root.submitted()
            Keys.onEscapePressed: root.escapePressed()
            Keys.onDownPressed: root.arrowDown()
            Keys.onUpPressed: root.arrowUp()
        }

        // Placeholder overlay
        Text {
            anchors.left: parent.left
            anchors.leftMargin: input.leftPadding
            anchors.right: parent.right
            anchors.rightMargin: input.rightPadding
            anchors.verticalCenter: parent.verticalCenter
            text: root.placeholder
            color: Appearance.colors.m3onSurfaceVariant
            font: input.font
            elide: Text.ElideRight
            opacity: input.text === "" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.medium3; easing.bezierCurve: Appearance.motion.easing.emphasized } }
        }

        // Clear chip
        Rectangle {
            id: clearChip
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 6
            width: 32
            height: 32
            radius: 16
            color: clearMa.containsMouse ? Appearance.colors.hover : Appearance.colors.transparent
            opacity: input.text.length > 0 ? 1 : 0
            visible: opacity > 0
            Behavior on color   { ColorAnimation  { duration: Appearance.motion.duration.effects } }
            Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }

            MaterialIcon {
                anchors.centerIn: parent
                text: "close"
                pixelSize: Appearance.typography.large
                color: Appearance.colors.m3onSurfaceVariant
            }

            MouseArea {
                id: clearMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    input.text = "";
                    input.forceActiveFocus();
                }
            }
        }
    }
}
