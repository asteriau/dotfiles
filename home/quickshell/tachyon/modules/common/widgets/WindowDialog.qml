import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

Rectangle {
    id: root

    property bool show: false
    default property alias contentData: contentColumn.data
    property real backgroundHeight: contentColumn.implicitHeight + dialogBackground.radius * 2 // dialogs with fill-height lists override this
    property real backgroundWidth: 350
    property real backgroundAnimationMovementDistance: 60
    
    signal dismiss()
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Escape) {
            root.dismiss();
            event.accepted = true;
        }
    }

    // Scrim in the panel's own surface tone, so content recedes into the card instead of going black
    color: ColorUtils.transparentize(Appearance.m3colors.m3surface, root.show ? 0.3 : 1)
    Behavior on color {
        animation: Appearance.animation.effectsDefault.colorAnimation.createObject(this)
    }
    visible: dialogBackground.implicitHeight > 0

    onShowChanged: {
        // Re-show restores the live binding rather than copying a value that may
        // be mid-collapse when a reopen lands during the exit
        dialogBackground.implicitHeight = show
            ? Qt.binding(() => root.backgroundHeight)
            : 0
    }

    radius: Appearance.rounding.screenRounding - Appearance.sizes.hyprlandGapsOut + 1

    MouseArea { // Clicking outside the dialog should dismiss
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        onPressed: root.dismiss()
    }

    Rectangle {
        id: dialogBackground
        anchors.horizontalCenter: parent.horizontalCenter
        radius: Appearance.rounding.large
        color: Appearance.m3colors.m3surfaceContainerHigh // Use opaque version of layer3
        
        property real targetY: root.height / 2 - root.backgroundHeight / 2
        y: root.show ? targetY : (targetY - root.backgroundAnimationMovementDistance)
        implicitWidth: root.backgroundWidth
        implicitHeight: root.backgroundHeight
        // Direction is read from each Behavior's targetValue (set and notified before
        // the animation starts), not from `show`, so it cannot depend on binding order
        Behavior on implicitHeight {
            id: heightBehavior
            animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => heightBehavior.targetValue > 0) })
        }
        Behavior on y {
            id: yBehavior
            animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => yBehavior.targetValue === dialogBackground.targetY) })
        }

        MouseArea { // So clicking inside the dialog won't dismiss
            anchors.fill: parent
            acceptedButtons: Qt.AllButtons
            hoverEnabled: true
        }

        ColumnLayout {
            id: contentColumn
            anchors {
                fill: parent
                margins: dialogBackground.radius
            }
            spacing: 16
            opacity: root.show ? 1 : 0
            Behavior on opacity {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }

        }
    }
}
