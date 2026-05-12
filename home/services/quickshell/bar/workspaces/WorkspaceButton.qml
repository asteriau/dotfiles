pragma ComponentBehavior: Bound

import QtQuick
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Widgets
import qs.components.surfaces
import qs.components.text
import qs.utils

// z:4 workspace button. Transparent hover disc plus number/dot/app-icon
// content, with optional monochrome tint for app icons. Clicking dispatches
// the Hyprland workspace switch.
Item {
    id: root

    required property int index

    // Inputs from the orchestrator.
    property int  group: 0
    property int  perGroup: 10
    property int  activeId: 1
    property var  occupied: []
    property real buttonWidth: 26
    property bool showNumbers: false

    readonly property int  workspaceValue: group * perGroup + index + 1
    readonly property bool isActive:      activeId === workspaceValue
    readonly property bool isOccupied:    occupied[index] ?? false

    // Icon sizing derived from the button width so the component stays
    // self-contained.
    readonly property real iconSize:          buttonWidth * 0.69
    readonly property real iconSizeShrinked:  buttonWidth * 0.55
    readonly property real iconMarginShrinked: -4

    implicitWidth:  buttonWidth
    implicitHeight: buttonWidth

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPressed: Hyprland.dispatch(`workspace ${root.workspaceValue}`)
    }

    // M3 state-layer overlay (clipped to the button circle).
    StateLayer {
        anchors.centerIn: parent
        width: root.buttonWidth
        height: width
        radius: width / 2
        hovered: ma.containsMouse
        pressed: ma.pressed
    }

    Item {
        id: content
        anchors.fill: parent

        scale: ma.pressed ? 0.96 : 1.0
        Behavior on scale {
            NumberAnimation { duration: Appearance.motion.duration.press; easing.type: Easing.OutQuad }
        }

        readonly property var biggestWindow:
            WorkspaceAppData.biggestWindowForWorkspace(root.workspaceValue)
        readonly property string iconSource:
            Quickshell.iconPath(
                WorkspaceIconSearch.guessIcon(biggestWindow?.class ?? ""),
                "image-missing")

        // Number text.
        ShadowText {
            anchors.centerIn: parent
            visible: opacity > 0
            opacity: root.showNumbers
                || (Config.workspaces.alwaysShowNumbers
                    && (!Config.workspaces.showAppIcons || !content.biggestWindow || root.showNumbers))
                ? 1 : 0
            z: 3

            text: root.workspaceValue
            font.pixelSize: text.toString().length > 1 ? 13 : 15
            font.family: Config.typography.family
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.isActive ? Appearance.colors.m3onPrimary :
                   root.isOccupied ? Appearance.colors.m3onSecondaryContainer : Appearance.colors.m3onSurfaceInactive

            Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
            Behavior on color   { ColorAnimation   { duration: Appearance.motion.duration.effects } }
        }

        // Flat dot for empty workspaces.
        Rectangle {
            anchors.centerIn: parent
            visible: opacity > 0
            opacity: (Config.workspaces.alwaysShowNumbers
                || root.showNumbers
                || (Config.workspaces.showAppIcons && content.biggestWindow)
                ) ? 0 : 1
            width:  root.buttonWidth * 0.15
            height: width
            radius: width / 2
            color: root.isActive ? Appearance.colors.m3onPrimary :
                   root.isOccupied ? Appearance.colors.m3onSecondaryContainer : Appearance.colors.m3onSurfaceInactive

            Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }
            Behavior on color   { ColorAnimation   { duration: Appearance.motion.duration.effects } }
        }

        // App icon.
        Item {
            anchors.centerIn: parent
            width:  root.buttonWidth
            height: root.buttonWidth
            visible: opacity > 0
            opacity: !Config.workspaces.showAppIcons ? 0 :
                     (content.biggestWindow && !root.showNumbers && Config.workspaces.showAppIcons) ?
                     1 : content.biggestWindow ? 1 : 0

            Behavior on opacity { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.OutCubic } }

            // Subtle scale bounce on active transition.
            scale: root.isActive ? 1.05 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: Appearance.motion.duration.spatial
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Appearance.motion.easing.emphasized
                }
            }

            IconImage {
                id: appIcon
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: (!root.showNumbers && Config.workspaces.showAppIcons) ?
                    (root.buttonWidth - root.iconSize) / 2 : root.iconMarginShrinked
                anchors.rightMargin: (!root.showNumbers && Config.workspaces.showAppIcons) ?
                    (root.buttonWidth - root.iconSize) / 2 : root.iconMarginShrinked
                source: content.iconSource
                implicitSize: (!root.showNumbers && Config.workspaces.showAppIcons) ?
                    root.iconSize : root.iconSizeShrinked

                Behavior on implicitSize         { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.motion.easing.emphasized } }
                Behavior on anchors.bottomMargin { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.motion.easing.emphasized } }
                Behavior on anchors.rightMargin  { NumberAnimation { duration: Appearance.motion.duration.effects; easing.type: Easing.BezierSpline; easing.bezierCurve: Appearance.motion.easing.emphasized } }
            }

            // Monochrome overlay
            Loader {
                active: Config.workspaces.monochromeIcons && !Config.workspaces.tintedIcons
                anchors.fill: appIcon

                sourceComponent: Item {
                    Desaturate {
                        id: desatIcon
                        visible: false
                        anchors.fill: parent
                        source: appIcon
                        desaturation: 0.8
                    }
                    ColorOverlay {
                        anchors.fill: desatIcon
                        source: desatIcon
                        readonly property color tintColor: root.isActive ? Appearance.colors.m3onPrimary : Appearance.colors.m3onSecondaryContainer
                        color: Qt.rgba(tintColor.r, tintColor.g, tintColor.b, 0.9)
                    }
                }
            }

            // Tinted icons overlay: desaturate + subtle accent wash
            Loader {
                active: Config.workspaces.tintedIcons
                anchors.fill: appIcon

                sourceComponent: Item {
                    Desaturate {
                        id: desatTinted
                        visible: false
                        anchors.fill: parent
                        source: appIcon
                        desaturation: 0.8
                    }
                    ColorOverlay {
                        anchors.fill: desatTinted
                        source: desatTinted
                        color: Qt.rgba(Appearance.colors.accent.r, Appearance.colors.accent.g, Appearance.colors.accent.b, 0.1)
                    }
                }
            }
        }
    }
}
