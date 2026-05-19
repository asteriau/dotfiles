import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.sidebar.quickToggles

GroupButton {
    id: button
    property string buttonIcon
    property string tooltipText
    baseWidth: 40
    baseHeight: 40
    clickedWidth: baseWidth + 20
    toggled: false
    buttonRadius: (altAction && toggled) ? Appearance.layout.radiusMd : Math.min(baseHeight, baseWidth) / 2
    buttonRadiusPressed: Appearance.layout.radiusSm

    contentItem: MaterialIcon {
        anchors.centerIn: parent
        pixelSize: 22
        fill: button.toggled ? 1 : 0
        color: button.toggled ? Appearance.colors.m3onPrimary : Appearance.colors.colOnLayer1
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: button.buttonIcon

        Behavior on color {
            ColorAnimation {
                duration: Appearance.motion.duration.effects
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.motion.easing.expressiveEffects
            }
        }
    }

    TextTooltip {
        id: tip
        targetItem: button
        targetRect: Qt.rect(button.width / 2, button.height + Appearance.layout.gapSm, 0, 0)
        targetText: button.tooltipText
        visible: false
    }

    Timer {
        id: hideTimer
        interval: 220
        onTriggered: tip.visible = false
    }

    onHoveredChanged: {
        if (button.hovered && button.tooltipText !== "") {
            hideTimer.stop();
            tip.visible = true;
        } else if (tip.visible) {
            tip.shown = false;
            hideTimer.restart();
        }
    }
}
