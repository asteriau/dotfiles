import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.components
import qs.utils

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: col.implicitHeight + 48
    radius: 10
    color: Qt.rgba(0.13, 0.13, 0.13, 0.5)

    ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 24
        spacing: 20

        SliderRow {
            Layout.fillWidth: true
            label: "Volume"
            value: PipeWireState.defaultSink?.audio?.volume ?? 0
            onMoved: v => {
                const a = PipeWireState.defaultSink?.audio;
                if (a)
                    a.volume = v;
            }
        }

        SliderRow {
            Layout.fillWidth: true
            label: "Brightness"
            value: BrightnessState.brightness
            onMoved: v => BrightnessState.setBrightness(v)
        }
    }

    component SliderRow: ColumnLayout {
        id: row
        property string label
        property real value
        signal moved(real v)
        spacing: 10

        Text {
            text: row.label
            color: Colors.foreground
            font.family: "Google Sans Flex"
            font.pixelSize: 14
            Layout.alignment: Qt.AlignLeft
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: 18

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.07)
            }

            Rectangle {
                height: parent.height
                width: Math.max(height, parent.width * Math.max(0, Math.min(1, row.value)))
                radius: height / 2
                color: Colors.accent
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPressed: ev => row.moved(Math.max(0, Math.min(1, ev.x / width)))
                onPositionChanged: ev => {
                    if (pressed)
                        row.moved(Math.max(0, Math.min(1, ev.x / width)));
                }
            }
        }
    }
}
