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
        spacing: 12

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
        signal moved(real v)
        spacing: 10

        Text {
            text: row.icon
            color: Colors.foreground
            font.family: "Material Symbols Rounded"
            font.pixelSize: 18
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            implicitHeight: 10

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
