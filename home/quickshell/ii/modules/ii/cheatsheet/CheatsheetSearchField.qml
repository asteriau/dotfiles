import QtQuick
import QtQuick.Controls
import qs.modules.common
import qs.modules.common.widgets

/**
 * Search field with a tonal shape pill that morphs once a query exists.
 * Port of the user's SettingsSearchField, on ii tokens.
 */
Item {
    id: root

    property alias text: input.text
    property string placeholder: "Search"

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

    Item { // Tonal icon pill, anchored so it never reflows
        id: iconPill
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 44
        height: 44

        MaterialShape {
            anchors.fill: parent
            color: Appearance.colors.colSecondaryContainer
            implicitSize: Math.max(width, height)
            shape: input.text === "" ? MaterialShape.Shape.Cookie7Sided : MaterialShape.Shape.Clover4Leaf
            Behavior on color {
                animation: Appearance.animation.effectsDefault.colorAnimation.createObject(this)
            }
        }

        MaterialSymbol {
            anchors.centerIn: parent
            text: input.text === "" ? "search" : "manage_search"
            iconSize: Appearance.font.pixelSize.huge
            color: Appearance.colors.colOnSecondaryContainer
        }
    }

    Item { // Field
        anchors.left: iconPill.right
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 44

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.large
            color: input.activeFocus ? Appearance.colors.colLayer2 : Appearance.colors.colLayer1
            Behavior on color {
                animation: Appearance.animation.effectsDefault.colorAnimation.createObject(this)
            }
        }

        TextField {
            id: input
            anchors.fill: parent
            leftPadding: 18
            rightPadding: clearChip.visible ? 44 : 18
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.colOnLayer0
            placeholderText: ""
            selectByMouse: true
            selectionColor: Appearance.colors.colPrimary
            selectedTextColor: Appearance.colors.colOnPrimary
            verticalAlignment: TextInput.AlignVCenter
            background: null

            onTextChanged: root.queryChanged(text)
            onAccepted: root.submitted()
            Keys.onEscapePressed: root.escapePressed()
            Keys.onDownPressed: root.arrowDown()
            Keys.onUpPressed: root.arrowUp()
        }

        Text { // Placeholder overlay
            anchors.left: parent.left
            anchors.leftMargin: input.leftPadding
            anchors.right: parent.right
            anchors.rightMargin: input.rightPadding
            anchors.verticalCenter: parent.verticalCenter
            text: root.placeholder
            color: Appearance.colors.colOnSurfaceVariant
            font: input.font
            elide: Text.ElideRight
            opacity: input.text === "" ? 1 : 0
            Behavior on opacity {
                animation: Appearance.animation.effectsDefault.numberAnimation.createObject(this)
            }
        }

        Rectangle { // Clear chip
            id: clearChip
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 6
            width: 32
            height: 32
            radius: Appearance.rounding.normal
            color: clearMa.containsMouse ? Appearance.colors.colLayer1Hover : "transparent"
            opacity: input.text.length > 0 ? 1 : 0
            visible: opacity > 0
            Behavior on color {
                animation: Appearance.animation.effectsDefault.colorAnimation.createObject(this)
            }
            Behavior on opacity {
                animation: Appearance.animation.effectsDefault.numberAnimation.createObject(this)
            }

            MaterialSymbol {
                anchors.centerIn: parent
                text: "close"
                iconSize: Appearance.font.pixelSize.large
                color: Appearance.colors.colOnSurfaceVariant
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
