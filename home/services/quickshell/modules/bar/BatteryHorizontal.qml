import QtQuick
import qs.modules.common.widgets
import qs.modules.common

Item {
    id: root

    required property real fraction
    required property bool charging
    required property bool low

    // Vertical-oriented Apple-style battery silhouette: body taller than wide, tip on top.
    property int  bodyW: 9
    property int  bodyH: 15
    property real bodyR: 2.5
    property real innerPad: 2
    property int  tipGap: 1
    property int  tipW: 5
    property real tipH: 2

    // Implicit size = body only; the tip is rendered above the body via a negative
    // anchor margin so this Item's vertical centre matches the visible body, not
    // the body+tip bounding box — keeps the icon optically centred with adjacent text.
    implicitWidth:  bodyW
    implicitHeight: bodyH

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: body.top
        anchors.bottomMargin: root.tipGap
        width: root.tipW
        height: root.tipH
        radius: 1
        color: Appearance.colors.m3outline
        antialiasing: true
    }

    Rectangle {
        id: body
        anchors.fill: parent
        radius: root.bodyR
        color: "transparent"
        border.width: 1
        border.color: Appearance.colors.m3outline
        antialiasing: true

        Rectangle {
            x: root.innerPad
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.innerPad
            width: root.bodyW - root.innerPad * 2
            height: Math.max(0, (root.bodyH - root.innerPad * 2) * root.fraction)
            radius: Math.max(0, root.bodyR - root.innerPad)
            color: root.low ? Appearance.colors.red : Appearance.colors.accent
            antialiasing: true

            Behavior on height {
                NumberAnimation { duration: Appearance.motion.duration.short4; easing.type: Easing.OutCubic }
            }
            Behavior on color {
                ColorAnimation  { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic }
            }
        }
    }

    MaterialIcon {
        anchors.centerIn: body
        visible: root.charging
        text: "bolt"
        pixelSize: 9
        fill: 1
        weight: Font.DemiBold
        color: Appearance.colors.background
    }
}
