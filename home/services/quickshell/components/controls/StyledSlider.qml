pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.components.shape
import qs.utils

Slider {
    id: root

    property list<real> stopIndicatorValues: [1]
    property list<real> dividerValues: []
    enum Configuration {
        Wavy = 4,
        XS = 12,
        S = 18,
        M = 30,
        L = 42,
        XL = 72
    }

    property var configuration: StyledSlider.Configuration.S

    property real handleDefaultWidth: 3
    property real handlePressedWidth: 1.5
    property color highlightColor: Colors.colPrimary
    property color trackColor: Colors.colSecondaryContainer
    property color handleColor: Colors.colPrimary
    property color dotColor: Colors.colOnSecondaryContainer
    property color dotColorHighlighted: Colors.m3onPrimary
    property real unsharpenRadius: 2
    property real trackWidth: configuration
    property real trackRadius: trackWidth >= StyledSlider.Configuration.XL ? 21
        : trackWidth >= StyledSlider.Configuration.L ? 12
        : trackWidth >= StyledSlider.Configuration.M ? 9
        : trackWidth >= StyledSlider.Configuration.S ? 6
        : height / 2
    property real handleHeight: (configuration === StyledSlider.Configuration.Wavy) ? 24 : Math.max(33, trackWidth + 9)
    property real handleWidth: root.pressed ? handlePressedWidth : handleDefaultWidth
    property real handleMargins: 4
    property real dividerMargins: 2
    property real trackDotSize: 3
    property bool wavy: configuration === StyledSlider.Configuration.Wavy
    property bool animateWave: true
    property real waveAmplitudeMultiplier: wavy ? 0.5 : 0
    property real waveFrequency: 6
    property real waveFps: 60

    leftPadding: handleMargins
    rightPadding: handleMargins
    property real effectiveDraggingWidth: width - leftPadding - rightPadding

    Layout.fillWidth: true
    from: 0
    to: 1

    Behavior on value {
        SmoothedAnimation {
            velocity: Appearance.motion.elementMoveFastVelocity
        }
    }

    Behavior on handleMargins {
        NumberAnimation {
            duration: Appearance.motion.duration.elementMoveFast
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Appearance.motion.easing.expressiveEffects
        }
    }

    component TrackDot: Rectangle {
        required property real value
        property real normalizedValue: (value - root.from) / (root.to - root.from)
        anchors.verticalCenter: parent.verticalCenter
        x: root.handleMargins + (normalizedValue * root.effectiveDraggingWidth) - (root.trackDotSize / 2)
        width: root.trackDotSize
        height: root.trackDotSize
        radius: 9999
        color: normalizedValue > root.visualPosition ? root.dotColor : root.dotColorHighlighted

        Behavior on color {
            ColorAnimation {
                duration: Appearance.motion.duration.elementMoveFast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.motion.easing.expressiveEffects
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: (mouse) => mouse.accepted = false
        cursorShape: root.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
    }

    background: Item {
        id: background
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.width
        implicitHeight: root.trackWidth
        property var normalized: root.dividerValues.map(v => (v - root.from) / (root.to - root.from))
        property var filtered: normalized.filter(v => Math.abs(v - root.visualPosition) * root.effectiveDraggingWidth > root.handleMargins + root.handleWidth / 2 - root.dividerMargins)
        property var leftValues: [0, ...filtered.filter(v => v < root.visualPosition), root.visualPosition]
        property var rightValues: [root.visualPosition, ...filtered.filter(v => v > root.visualPosition), 1]
        property var leftWidths: leftValues.map((v, i, a) => a[i + 1] - v).slice(0, -1)
        property var rightWidths: rightValues.map((v, i, a) => a[i + 1] - v).slice(0, -1)

        Repeater {
            model: background.leftWidths.length

            Loader {
                required property int index
                anchors.verticalCenter: background.verticalCenter
                property real leftMargin: index > 0 ? root.dividerMargins : 0
                property real rightMargin: index < background.leftWidths.length - 1 ? root.dividerMargins : root.handleMargins
                x: background.leftValues[index] * root.effectiveDraggingWidth + leftMargin + (index > 0 ? root.leftPadding : 0)
                width: background.leftWidths[index] * root.effectiveDraggingWidth - leftMargin - rightMargin - (index === background.leftWidths.length - 1 ? root.handleWidth / 2 : 0) + (index === 0 ? root.leftPadding : 0)
                height: root.trackWidth
                active: !root.wavy
                sourceComponent: Rectangle {
                    color: root.highlightColor
                    topLeftRadius: index === 0 ? root.trackRadius : root.unsharpenRadius
                    bottomLeftRadius: index === 0 ? root.trackRadius : root.unsharpenRadius
                    topRightRadius: root.unsharpenRadius
                    bottomRightRadius: root.unsharpenRadius
                }
            }
        }

        Repeater {
            model: background.leftWidths.length

            Loader {
                required property int index
                anchors.verticalCenter: background.verticalCenter
                property real leftMargin: index > 0 ? root.dividerMargins : 0
                property real rightMargin: index < background.leftWidths.length - 1 ? root.dividerMargins : root.handleMargins
                x: background.leftValues[index] * root.effectiveDraggingWidth + leftMargin + (index > 0 ? root.leftPadding : 0)
                width: background.leftWidths[index] * root.effectiveDraggingWidth - leftMargin - rightMargin - (index === background.leftWidths.length - 1 ? root.handleWidth / 2 : 0) + (index === 0 ? root.leftPadding : 0)
                height: root.height
                active: root.wavy
                sourceComponent: WavyLine {
                    id: wavyFill
                    frequency: root.waveFrequency
                    fullLength: root.width
                    color: root.highlightColor
                    amplitudeMultiplier: root.wavy ? 0.5 : 0
                    width: parent.width
                    height: root.trackWidth
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
        }

        Repeater {
            model: background.rightWidths.length

            Rectangle {
                required property int index
                anchors.verticalCenter: background.verticalCenter
                property real leftMargin: index > 0 ? root.dividerMargins : root.handleMargins
                property real rightMargin: index < background.rightWidths.length - 1 ? root.dividerMargins : 0
                x: background.rightValues[index] * root.effectiveDraggingWidth + leftMargin + (index === 0 ? root.handleWidth / 2 : 0) + root.leftPadding
                width: background.rightWidths[index] * root.effectiveDraggingWidth - leftMargin - rightMargin - (index === 0 ? root.handleWidth / 2 : 0) + (index === background.rightWidths.length - 1 ? root.rightPadding : 0)
                height: root.trackWidth
                color: root.trackColor
                topRightRadius: index === background.rightWidths.length - 1 ? root.trackRadius : root.unsharpenRadius
                bottomRightRadius: index === background.rightWidths.length - 1 ? root.trackRadius : root.unsharpenRadius
                topLeftRadius: root.unsharpenRadius
                bottomLeftRadius: root.unsharpenRadius
            }
        }

        Repeater {
            model: root.stopIndicatorValues
            TrackDot {
                required property real modelData
                value: modelData
                anchors.verticalCenter: parent?.verticalCenter
            }
        }
    }

    handle: Rectangle {
        id: handle

        implicitWidth: root.handleWidth
        implicitHeight: root.handleHeight
        x: root.leftPadding + (root.visualPosition * root.effectiveDraggingWidth) - (root.handleWidth / 2)
        anchors.verticalCenter: parent.verticalCenter
        radius: 9999
        color: root.handleColor

        Behavior on implicitWidth {
            NumberAnimation {
                duration: Appearance.motion.duration.elementMoveFast
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Appearance.motion.easing.expressiveEffects
            }
        }
    }
}
