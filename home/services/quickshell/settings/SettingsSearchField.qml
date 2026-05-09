import QtQuick
import QtQuick.Controls
import qs.components.shape
import qs.components.text
import qs.utils

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
            color: Colors.secondaryContainer
            implicitSize: Math.max(width, height)
            shape: input.text === ""
                ? MaterialShape.Shape.Cookie7Sided
                : MaterialShape.Shape.Clover4Leaf

            Behavior on color {
                ColorAnimation { duration: M3Easing.durationMedium3; easing.bezierCurve: M3Easing.emphasized }
            }
        }

        MaterialIcon {
            anchors.centerIn: parent
            text: input.text === "" ? "search" : "manage_search"
            pixelSize: Config.typography.huge
            color: Colors.m3onSecondaryContainer
        }
    }

    // Field
    Item {
        anchors.left: iconPill.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 44

        Rectangle {
            anchors.fill: parent
            radius: 22
            color: input.activeFocus ? Colors.surfaceContainerHigh : Colors.surfaceContainer
            Behavior on color { ColorAnimation { duration: M3Easing.effectsDuration } }
        }

        TextField {
            id: input
            anchors.fill: parent
            leftPadding: 18
            rightPadding: clearChip.visible ? 44 : 18
            font.family: Config.typography.family
            font.pixelSize: Config.typography.normal
            color: Colors.foreground
            placeholderText: ""
            selectByMouse: true
            selectionColor: Colors.accent
            selectedTextColor: Colors.accentText
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
            color: Colors.m3onSurfaceVariant
            font: input.font
            elide: Text.ElideRight
            opacity: input.text === "" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: M3Easing.durationMedium3; easing.bezierCurve: M3Easing.emphasized } }
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
            color: clearMa.containsMouse ? Colors.hover : Colors.transparent
            opacity: input.text.length > 0 ? 1 : 0
            visible: opacity > 0
            Behavior on color   { ColorAnimation  { duration: M3Easing.effectsDuration } }
            Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration; easing.type: Easing.OutCubic } }

            MaterialIcon {
                anchors.centerIn: parent
                text: "close"
                pixelSize: Config.typography.large
                color: Colors.m3onSurfaceVariant
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
