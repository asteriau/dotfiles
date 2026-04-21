import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.components
import qs.utils

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + 28
    radius: 10
    color: Qt.rgba(0.13, 0.13, 0.13, 0.5)

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        SliderRow {
            Layout.fillWidth: true
            icon: "volume_up"
            value: PipeWireState.defaultSink?.audio?.volume ?? 0
            onMoved: v => {
                const a = PipeWireState.defaultSink?.audio;
                if (a)
                    a.volume = v;
            }
        }

        SliderRow {
            Layout.fillWidth: true
            icon: "brightness_6"
            value: BrightnessState.brightness
            onMoved: v => BrightnessState.setBrightness(v)
        }
    }

    component SliderRow: RowLayout {
        id: row
        property string icon
        property real value
        property real visualValue: value
        signal moved(real v)
        spacing: 12

        // M3 expressive dimensions.
        readonly property real trackWidth: 18
        readonly property real trackRadius: 6
        readonly property real unsharpenRadius: 2
        readonly property real handleMargins: 4
        readonly property real handleDefaultWidth: 3
        readonly property real handlePressedWidth: 1.5
        readonly property real handleHeight: Math.max(33, trackWidth + 9)
        readonly property real stopDotSize: 3

        onValueChanged: {
            if (!dragMA.pressed)
                visualValue = value;
        }

        Text {
            text: row.icon
            color: Colors.foreground
            font.family: "Material Symbols Rounded"
            font.pixelSize: 20
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            id: sliderArea
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: row.handleHeight

            readonly property real pos: Math.max(0, Math.min(1, row.visualValue))
            property real handleWidth: dragMA.pressed ? row.handlePressedWidth : row.handleDefaultWidth
            readonly property real effectiveWidth: width - row.handleMargins * 2
            readonly property real handleX: row.handleMargins + pos * effectiveWidth - handleWidth / 2

            Behavior on handleWidth {
                NumberAnimation {
                    duration: 160
                    easing.type: Easing.OutCubic
                }
            }

            // Filled (left) segment.
            Rectangle {
                id: fill
                anchors.verticalCenter: parent.verticalCenter
                height: row.trackWidth
                x: 0
                width: Math.max(0, sliderArea.handleX - row.handleMargins)
                color: Colors.accent
                topLeftRadius: row.trackRadius
                bottomLeftRadius: row.trackRadius
                topRightRadius: row.unsharpenRadius
                bottomRightRadius: row.unsharpenRadius

                Behavior on width {
                    NumberAnimation {
                        duration: 90
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Track (right) segment.
            Rectangle {
                id: track
                anchors.verticalCenter: parent.verticalCenter
                height: row.trackWidth
                x: sliderArea.handleX + sliderArea.handleWidth + row.handleMargins
                width: Math.max(0, parent.width - x)
                color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.22)
                topLeftRadius: row.unsharpenRadius
                bottomLeftRadius: row.unsharpenRadius
                topRightRadius: row.trackRadius
                bottomRightRadius: row.trackRadius

                Behavior on x {
                    NumberAnimation {
                        duration: 90
                        easing.type: Easing.OutCubic
                    }
                }
            }

            // Stop dot at value=1, hidden when fill reaches it.
            Rectangle {
                id: stopDot
                anchors.verticalCenter: parent.verticalCenter
                width: row.stopDotSize
                height: row.stopDotSize
                radius: height / 2
                x: parent.width - row.handleMargins - width - 2
                color: sliderArea.pos < 0.98 ? Qt.rgba(Colors.foreground.r, Colors.foreground.g, Colors.foreground.b, 0.8) : Colors.background
                visible: sliderArea.pos < 0.995
            }

            // Handle pill.
            Rectangle {
                id: handle
                anchors.verticalCenter: parent.verticalCenter
                width: sliderArea.handleWidth
                height: row.handleHeight
                radius: width / 2
                color: Colors.accent
                x: sliderArea.handleX

                Behavior on x {
                    NumberAnimation {
                        duration: 90
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                id: dragMA
                anchors.fill: parent
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
                preventStealing: true

                function valueAt(x) {
                    const w = sliderArea.effectiveWidth;
                    if (w <= 0)
                        return 0;
                    return Math.max(0, Math.min(1, (x - row.handleMargins) / w));
                }

                onPressed: ev => {
                    const v = valueAt(ev.x);
                    row.visualValue = v;
                    row.moved(v);
                }
                onPositionChanged: ev => {
                    if (pressed) {
                        const v = valueAt(ev.x);
                        row.visualValue = v;
                        row.moved(v);
                    }
                }
                onReleased: {
                    row.visualValue = row.value;
                }
            }
        }
    }
}
