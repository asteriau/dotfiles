import QtQuick
import QtQuick.Layouts
import qs.utils

// Floating dialog with scrim. Card is horizontally centered, slides
// down `movement` pixels into place when shown. Card height is fixed
// (`backgroundHeight`) so child ListViews can use Layout.fillHeight.
//
// Children added via the default property go inside the card's
// ColumnLayout (16px spacing, padding = card radius).
Rectangle {
    id: root

    property bool show: false
    property real backgroundWidth: 350
    property real backgroundHeight: 540
    property real movement: 60

    signal dismiss

    default property alias contentData: contentColumn.data

    color: root.show ? Qt.rgba(0, 0, 0, 0.45) : Qt.rgba(0, 0, 0, 0)
    Behavior on color { Motion.ColorFade {} }
    visible: card.implicitHeight > 0
    radius: Config.layout.cardRadius
    clip: true

    // Outside-click dismiss.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        onPressed: root.dismiss()
        cursorShape: Qt.ArrowCursor
    }

    Rectangle {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        radius: Config.layout.radiusLg
        color: Colors.surfaceContainerHigh

        readonly property real _cappedH: Math.min(root.backgroundHeight, root.height - Config.layout.gapLg * 2)
        readonly property real targetY: (root.height - _cappedH) / 2

        y: root.show ? targetY : (targetY - root.movement)
        implicitWidth: Math.min(root.backgroundWidth, root.width - Config.layout.gapMd * 2)
        implicitHeight: root.show ? _cappedH : 0

        Behavior on implicitHeight {
            NumberAnimation {
                id: hAnim
                duration: M3Easing.elementMoveFastDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.show ? M3Easing.emphasizedDecel : M3Easing.emphasizedAccel
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: hAnim.duration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.show ? M3Easing.emphasizedDecel : M3Easing.emphasizedAccel
            }
        }

        // Eat clicks inside the card so the scrim MouseArea below
        // doesn't dismiss when the user interacts with rows.
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            hoverEnabled: true
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: card.radius
            spacing: 16
            opacity: root.show ? 1 : 0
            Behavior on opacity { Motion.Fade {} }
        }
    }
}
