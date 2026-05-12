import QtQuick
import QtQuick.Shapes
import QtQuick.Effects

Item {
    id: root

    property real boltHeight: 120
    property real boltWidth: 28
    property color strokeColor: "#FFF4C8"
    property color fillColor: Qt.rgba(1, 0.95, 0.7, 0.45)
    property color haloColor: Qt.rgba(1, 0.97, 0.82, 1)
    property int jitterSeed: 0
    property real currentOpacity: 0

    implicitWidth: boltWidth * 1.6
    implicitHeight: boltHeight

    function flash() {
        jitterSeed = Math.random() * 10000;
        flashAnim.restart();
    }

    function _j(i) {
        const s = jitterSeed + i * 37.17;
        return (Math.sin(s) * 0.5 + 0.5);
    }

    Rectangle {
        id: halo
        anchors.centerIn: bolt
        width: root.boltWidth * 3.2
        height: root.boltHeight * 1.15
        radius: width / 2
        color: root.haloColor
        opacity: root.currentOpacity * 0.28

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.85
            blurMax: 42
        }
    }

    Shape {
        id: bolt
        anchors.fill: parent
        opacity: root.currentOpacity
        antialiasing: true
        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 0.35
            blurMax: 18
            brightness: 0.25
        }

        ShapePath {
            strokeWidth: 3.2
            strokeColor: root.strokeColor
            fillColor: root.fillColor
            joinStyle: ShapePath.MiterJoin
            capStyle: ShapePath.FlatCap

            startX: root.boltWidth * 0.9
            startY: 0
            PathLine {
                x: root.boltWidth * (0.15 + root._j(1) * 0.15)
                y: root.boltHeight * 0.42
            }
            PathLine {
                x: root.boltWidth * (0.75 + root._j(2) * 0.15)
                y: root.boltHeight * 0.48
            }
            PathLine {
                x: root.boltWidth * (0.05 + root._j(3) * 0.15)
                y: root.boltHeight * 0.92
            }
            PathLine {
                x: root.boltWidth * (0.4 + root._j(4) * 0.2)
                y: root.boltHeight
            }
        }
    }

    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: root; property: "currentOpacity"; from: 0; to: 1; duration: 30 }
        PauseAnimation { duration: 60 }
        NumberAnimation { target: root; property: "currentOpacity"; to: 0; duration: 320; easing.type: Easing.BezierSpline; easing.bezierCurve: [0.05, 0.7, 0.1, 1, 1, 1] }
    }
}
