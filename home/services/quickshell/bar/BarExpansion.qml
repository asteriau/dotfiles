import QtQuick
import qs.utils

Item {
    id: root

    required property BarExpansionState expansionState

    readonly property bool vertical: Config.bar.vertical
    readonly property bool onEnd: Config.bar.onEnd
    readonly property real outerRadius: Config.layout.radiusXl
    readonly property real nonAnimWidth: content.currentWidth
    readonly property real nonAnimHeight: content.currentHeight
    property real offsetScale: expansionState.hasCurrent ? 0 : 1

    implicitWidth: vertical ? content.width * (1 - offsetScale) : content.width
    implicitHeight: vertical ? content.height : content.height * (1 - offsetScale)
    width: implicitWidth
    height: implicitHeight
    visible: width > 0 && height > 0
    clip: true

    Behavior on offsetScale { Motion.Element {} }
    Behavior on x { Motion.Element {} }
    Behavior on y {
        enabled: !root.vertical
        Motion.Element {}
    }

    Item {
        id: content

        readonly property Popout currentPopout: loaders.children.find(c => c.shouldBeActive) ?? null
        readonly property Popout activePopout: loaders.children.find(c => c.active) ?? null
        readonly property real currentWidth: (currentPopout ?? activePopout)?.implicitWidth ?? 0
        readonly property real currentHeight: (currentPopout ?? activePopout)?.implicitHeight ?? 0

        x: root.vertical
            ? (root.onEnd
                ? root.width - width + (width + 5) * root.offsetScale
                : (-width - 5) * root.offsetScale)
            : 0
        y: root.vertical
            ? 0
            : (root.onEnd
                ? root.height - height + (height + 5) * root.offsetScale
                : (-height - 5) * root.offsetScale)
        width: currentWidth
        height: currentHeight

        Behavior on width {
            enabled: false
            Motion.Element {}
        }

        Behavior on height {
            enabled: false
            Motion.Element {}
        }

        Rectangle {
            anchors.fill: parent
            color: Appearance.colors.background
            radius: root.outerRadius

            Behavior on color { Motion.ColorFade {} }
        }

        Rectangle {
            visible: root.vertical
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: root.onEnd ? undefined : parent.left
            anchors.right: root.onEnd ? parent.right : undefined
            width: root.outerRadius
            color: Appearance.colors.background
        }

        Rectangle {
            visible: !root.vertical
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: root.onEnd ? undefined : parent.top
            anchors.bottom: root.onEnd ? parent.bottom : undefined
            height: root.outerRadius
            color: Appearance.colors.background
        }

        Item {
            id: loaders

            anchors.fill: parent

            Popout {
                name: "clock"
                sourceComponent: ClockExpansionContent {}
            }

            Popout {
                name: "resources"
                sourceComponent: ResourcesExpansionContent {}
            }
        }
    }

    component Popout: Loader {
        id: popout

        required property string name
        readonly property bool shouldBeActive: root.expansionState.hasCurrent && root.expansionState.currentName === name

        anchors.centerIn: parent
        opacity: 0
        scale: 0.8
        active: false

        states: State {
            name: "active"
            when: popout.shouldBeActive

            PropertyChanges {
                popout.active: true
                popout.opacity: 1
                popout.scale: 1
            }
        }

        transitions: [
            Transition {
                from: ""
                to: "active"

                SequentialAnimation {
                    PropertyAction {
                        target: popout
                        property: "active"
                    }
                    NumberAnimation {
                        properties: "opacity,scale"
                        duration: Appearance.motion.duration.effects
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.expressiveEffects
                    }
                }
            },
            Transition {
                from: "active"
                to: ""

                SequentialAnimation {
                    NumberAnimation {
                        properties: "opacity,scale"
                        duration: Appearance.motion.duration.effects
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: Appearance.motion.easing.expressiveEffects
                    }
                    PropertyAction {
                        target: popout
                        property: "active"
                    }
                }
            }
        ]
    }
}
