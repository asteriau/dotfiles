import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Templates as T
import QtQuick.Layouts

T.Button {
    id: root
    property bool toggled
    property string buttonText
    property real buttonRadius: Appearance.layout.radiusMd
    property real buttonRadiusPressed: Appearance.layout.radiusMd
    property var downAction
    property var releaseAction
    property var altAction
    property var middleClickAction
    property bool bounce: true
    property real baseWidth: contentItem.implicitWidth + horizontalPadding * 2
    property real baseHeight: contentItem.implicitHeight + verticalPadding * 2
    property bool enableImplicitWidthAnimation: true
    property bool enableImplicitHeightAnimation: true
    property real clickedWidth: baseWidth + (isAtSide ? 10 : 20)
    property real clickedHeight: baseHeight
    property var parentGroup: root.parent
    property int indexInParent: parentGroup?.children.indexOf(root) ?? -1
    property int clickIndex: parentGroup?.clickIndex ?? -1
    property bool isAtSide: indexInParent === 0 || indexInParent === (parentGroup?.childrenCount - 1)

    Layout.fillWidth: (clickIndex - 1 <= indexInParent && indexInParent <= clickIndex + 1)
    Layout.fillHeight: (clickIndex - 1 <= indexInParent && indexInParent <= clickIndex + 1)
    implicitWidth: (root.down && bounce) ? clickedWidth : baseWidth
    implicitHeight: (root.down && bounce) ? clickedHeight : baseHeight

    property color colBackground: "transparent"
    property color colBackgroundHover: Appearance.colors.colLayer1Hover
    property color colBackgroundActive: Appearance.colors.colLayer1Active
    property color colBackgroundToggled: Appearance.colors.colPrimary
    property color colBackgroundToggledHover: Appearance.colors.colPrimaryHover
    property color colBackgroundToggledActive: Appearance.colors.colPrimaryActive
    property color colFocusRing: Appearance.colors.colOnSecondaryContainer

    property real radius: root.down ? root.buttonRadiusPressed : root.buttonRadius
    property real leftRadius: root.down ? root.buttonRadiusPressed : root.buttonRadius
    property real rightRadius: root.down ? root.buttonRadiusPressed : root.buttonRadius
    property color color: root.enabled ? (root.toggled ? (root.down ? colBackgroundToggledActive :
                                                                      root.hovered
                                                                      ? colBackgroundToggledHover :
                                                                        colBackgroundToggled) : (root.down
                                                                                                 ? colBackgroundActive :
                                                                                                   root.hovered
                                                                                                   ? colBackgroundHover :
                                                                                                     colBackground)) :
                                         colBackground

    onDownChanged: {
        if (root.down) {
            if (root.parent.clickIndex !== undefined) {
                root.parent.clickIndex = parent.children.indexOf(root);
            }
        }
    }

    Behavior on implicitWidth {
        enabled: root.enableImplicitWidthAnimation
        NumberAnimation {
            duration: Appearance.motion.duration.clickBounce
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.motion.easing.expressiveDefaultSpatial
        }
    }
    Behavior on implicitHeight {
        enabled: root.enableImplicitHeightAnimation
        NumberAnimation {
            duration: Appearance.motion.duration.clickBounce
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.motion.easing.expressiveDefaultSpatial
        }
    }
    Behavior on leftRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
    Behavior on rightRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    property alias mouseArea: buttonMouseArea
    MouseArea {
        id: buttonMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: event => {
                       if (event.button === Qt.RightButton) {
                           if (root.altAction)
                           root.altAction();
                           return;
                       }
                       if (event.button === Qt.MiddleButton) {
                           if (root.middleClickAction)
                           root.middleClickAction();
                           return;
                       }
                       root.down = true;
                       if (root.downAction)
                       root.downAction();
                   }
        onReleased: event => {
                        root.down = false;
                        if (event.button != Qt.LeftButton)
                        return;
                        if (root.releaseAction)
                        root.releaseAction();
                    }
        onClicked: event => {
                       if (event.button != Qt.LeftButton)
                       return;
                       root.click();
                   }
        onCanceled: event => {
                        root.down = false;
                    }
        onPressAndHold: () => {
                            if (root.altAction)
                            root.altAction();
                            root.down = false;
                        }
    }

    background: Rectangle {
        id: buttonBackground
        topLeftRadius: root.leftRadius
        topRightRadius: root.rightRadius
        bottomLeftRadius: root.leftRadius
        bottomRightRadius: root.rightRadius
        implicitHeight: 50
        color: root.color
        Behavior on color {
            ColorAnimation {
                duration: Appearance.motion.duration.effects
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.motion.easing.expressiveEffects
            }
        }
    }

    z: visualFocus ? 1 : 0
    Rectangle {
        id: focusRing
        topLeftRadius: root.leftRadius - anchors.margins
        topRightRadius: root.rightRadius - anchors.margins
        bottomLeftRadius: root.leftRadius - anchors.margins
        bottomRightRadius: root.rightRadius - anchors.margins
        visible: root.visualFocus
        color: "transparent"
        anchors {
            fill: parent
            margins: -4
        }
        border {
            color: root.colFocusRing
            width: 2
        }
    }

    contentItem: StyledText {
        text: root.buttonText
    }
}
