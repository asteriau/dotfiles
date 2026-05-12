pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import qs.components.shape
import qs.utils

ProgressBar {
    id: root
    property real valueBarWidth: 120
    property real valueBarHeight: 4
    property real valueBarGap: 4
    property color highlightColor: Appearance.colors.colPrimary
    property color trackColor: Appearance.colors.colSecondaryContainer
    property bool wavy: false
    property bool animateWave: true
    property real waveAmplitudeMultiplier: wavy ? 0.5 : 0
    property real waveFrequency: 6
    property real waveFps: 60

    Behavior on waveAmplitudeMultiplier {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    Behavior on value {
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }

    background: Item {
        implicitHeight: root.valueBarHeight
        implicitWidth: root.valueBarWidth
    }

    contentItem: Item {
        id: contentItem
        anchors.fill: parent

        Loader {
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            active: root.wavy
            sourceComponent: WavyLine {
                id: wavyFill
                frequency: root.waveFrequency
                color: root.highlightColor
                amplitudeMultiplier: root.wavy ? 0.5 : 0
                height: contentItem.height * 6
                width: contentItem.width * root.visualPosition
                lineWidth: contentItem.height
                fullLength: root.width
                Connections {
                    target: root
                    function onValueChanged() { wavyFill.requestPaint(); }
                    function onHighlightColorChanged() { wavyFill.requestPaint(); }
                }
                FrameAnimation {
                    running: root.animateWave
                    onTriggered: {
                        wavyFill.requestPaint();
                    }
                }
            }
        }

        Loader {
            active: !root.wavy
            sourceComponent: Rectangle {
                anchors.left: parent.left
                width: contentItem.width * root.visualPosition
                height: contentItem.height
                radius: height / 2
                color: root.highlightColor
            }
        }

        Rectangle {
            anchors.right: parent.right
            width: (1 - root.visualPosition) * parent.width - root.valueBarGap
            height: parent.height
            radius: height / 2
            color: root.trackColor
        }

        Rectangle {
            anchors.right: parent.right
            width: root.valueBarGap
            height: root.valueBarGap
            radius: height / 2
            color: root.highlightColor
        }
    }
}
