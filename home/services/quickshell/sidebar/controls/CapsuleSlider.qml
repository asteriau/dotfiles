import QtQuick
import QtQuick.Layouts
import qs.utils

Item {
    id: root

    property string icon
    property real value: 0
    property real visualValue: value
    property bool muted: false
    signal moved(real v)

    Layout.fillWidth: true
    Layout.preferredHeight: 56
    implicitHeight: 56

    onValueChanged: {
        if (!ma.pressed)
            visualValue = value;
    }

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: height / 2
        color: Colors.surfaceContainerHigh
        antialiasing: true
        clip: true

        Rectangle {
            id: fill
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: Math.max(0, Math.min(1, root.visualValue)) * parent.width
            color: root.muted ? Colors.surfaceContainerHighest : Colors.foreground
            antialiasing: true
            topLeftRadius: parent.height / 2
            bottomLeftRadius: parent.height / 2
            topRightRadius: 0
            bottomRightRadius: 0

            Behavior on width {
                enabled: !ma.pressed
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        font.family: "Material Symbols Rounded"
        font.pixelSize: 20
        font.variableAxes: ({
                FILL: 1,
                wght: 400,
                opsz: 24,
                GRAD: 0
            })
        color: root.visualValue > 0.5 && !root.muted ? Colors.background : Colors.m3onSurfaceVariant
        renderType: Text.NativeRendering
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        text: "chevron_right"
        font.family: "Material Symbols Rounded"
        font.pixelSize: 16
        color: Colors.m3onSurfaceVariant
        renderType: Text.NativeRendering
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        preventStealing: true
        cursorShape: Qt.PointingHandCursor

        function valueAt(x) {
            const w = width;
            if (w <= 0)
                return 0;
            return Math.max(0, Math.min(1, x / w));
        }

        onPressed: ev => {
            const v = valueAt(ev.x);
            root.visualValue = v;
            root.moved(v);
        }
        onPositionChanged: ev => {
            if (pressed) {
                const v = valueAt(ev.x);
                root.visualValue = v;
                root.moved(v);
            }
        }
        onReleased: {
            root.visualValue = root.value;
        }
    }
}
