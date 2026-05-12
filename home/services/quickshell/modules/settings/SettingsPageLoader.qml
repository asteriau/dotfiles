import QtQuick
import qs.modules.common

Item {
    id: root

    required property string source
    required property bool active

    signal pageReady(Item page)

    readonly property Item currentItem: frontIsA ? loaderA.item : loaderB.item

    property bool frontIsA: true

    onSourceChanged: {
        if (!loaderA.item && !loaderB.item) return;
        const incoming = frontIsA ? loaderB : loaderA;
        incoming.source = source;
        frontIsA = !frontIsA;
    }

    Loader {
        id: loaderA
        anchors.fill: parent
        asynchronous: true
        source: root.source
        readonly property bool targetVisible: root.active && root.frontIsA
        opacity: targetVisible ? 1 : 0
        visible: opacity > 0
        onStatusChanged: if (status === Loader.Ready && root.frontIsA) root.pageReady(item)
        transform: Translate {
            y: loaderA.targetVisible ? 0 : 14
            Behavior on y {
                NumberAnimation {
                    duration: Appearance.motion.duration.spatial
                    easing.bezierCurve: Appearance.motion.easing.emphasized
                    easing.type: Easing.BezierSpline
                }
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.motion.duration.spatial
                easing.bezierCurve: Appearance.motion.easing.emphasized
                easing.type: Easing.BezierSpline
            }
        }
    }

    Loader {
        id: loaderB
        anchors.fill: parent
        asynchronous: true
        readonly property bool targetVisible: root.active && !root.frontIsA
        opacity: targetVisible ? 1 : 0
        visible: opacity > 0
        onStatusChanged: if (status === Loader.Ready && !root.frontIsA) root.pageReady(item)
        transform: Translate {
            y: loaderB.targetVisible ? 0 : 14
            Behavior on y {
                NumberAnimation {
                    duration: Appearance.motion.duration.spatial
                    easing.bezierCurve: Appearance.motion.easing.emphasized
                    easing.type: Easing.BezierSpline
                }
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.motion.duration.spatial
                easing.bezierCurve: Appearance.motion.easing.emphasized
                easing.type: Easing.BezierSpline
            }
        }
    }
}
