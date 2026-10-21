import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property string text
    property bool shown: false
    property real enterOffsetY: 4 // towards the anchor; tooltips sit above their item by default
    property real horizontalPadding: 10
    property real verticalPadding: 5
    property alias font: tooltipTextObject.font
    implicitWidth: tooltipTextObject.implicitWidth + 2 * root.horizontalPadding
    implicitHeight: tooltipTextObject.implicitHeight + 2 * root.verticalPadding

    property bool isVisible: backgroundRectangle.implicitHeight > 0

    Rectangle {
        id: backgroundRectangle
        anchors {
            bottom: root.bottom
            horizontalCenter: root.horizontalCenter
        }
        color: Appearance?.colors.colTooltip ?? "#3C4043"
        radius: Appearance?.rounding.verysmall ?? 7
        opacity: shown ? 1 : 0
        scale: shown ? 1 : 0.9
        transform: Translate {
            y: root.shown ? 0 : root.enterOffsetY
            // Direction from the Behavior's targetValue, not `shown`: independent of binding order
            Behavior on y {
                id: offsetBehavior
                animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => offsetBehavior.targetValue === 0) })
            }
        }
        implicitWidth: shown ? (tooltipTextObject.implicitWidth + 2 * root.horizontalPadding) : 0
        implicitHeight: shown ? (tooltipTextObject.implicitHeight + 2 * root.verticalPadding) : 0
        clip: true

        // Width/height collapse to 0 on hide, so they take the enter/exit pair rather
        // than a spatial curve (overshoot below zero would show as a flicker)
        Behavior on implicitWidth {
            id: widthBehavior
            animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => widthBehavior.targetValue > 0) })
        }
        Behavior on implicitHeight {
            id: heightBehavior
            animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => heightBehavior.targetValue > 0) })
        }
        Behavior on opacity {
            animation: Appearance?.animation.effectsDefault.numberAnimation.createObject(this)
        }
        Behavior on scale {
            id: scaleBehavior
            animation: Appearance.animation.reveal.createObject(this, { opening: Qt.binding(() => scaleBehavior.targetValue === 1) })
        }

        StyledText {
            id: tooltipTextObject
            anchors.centerIn: parent
            text: root.text
            font.pixelSize: Appearance?.font.pixelSize.smaller ?? 14
            font.hintingPreference: Font.PreferNoHinting // Prevent shaky text
            color: Appearance?.colors.colOnTooltip ?? "#FFFFFF"
            wrapMode: Text.Wrap
        }
    }   
}

