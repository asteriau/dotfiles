import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.utils

Item {
    id: root

    property string icon
    property real value: 0
    property real visualValue: value
    signal moved(real v)

    implicitWidth: 56
    implicitHeight: 132

    onValueChanged: {
        if (!ma.pressed)
            visualValue = value;
    }

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: 28
        color: Colors.elevated
        antialiasing: true
    }

    Item {
        id: fillClip
        anchors.fill: parent
        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: fillMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1.0
        }

        Rectangle {
            id: fill
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: Math.max(0, Math.min(1, root.visualValue)) * parent.height
            color: Colors.accent
            antialiasing: true

            Behavior on height {
                enabled: !ma.pressed
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Item {
        id: fillMask
        anchors.fill: parent
        visible: false
        layer.enabled: true
        Rectangle {
            anchors.fill: parent
            radius: 28
            color: "black"
            antialiasing: true
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        text: root.icon
        font.family: "Material Symbols Rounded"
        font.pixelSize: 20
        font.variableAxes: ({
                FILL: 1,
                wght: 400,
                opsz: 24,
                GRAD: 0
            })
        color: root.visualValue > 0.2 ? Colors.m3onPrimary : Colors.m3onSurfaceVariant
        renderType: Text.NativeRendering
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        preventStealing: true
        cursorShape: Qt.PointingHandCursor

        function valueAt(y) {
            const h = height;
            if (h <= 0)
                return 0;
            return Math.max(0, Math.min(1, 1 - y / h));
        }

        onPressed: ev => {
            const v = valueAt(ev.y);
            root.visualValue = v;
            root.moved(v);
        }
        onPositionChanged: ev => {
            if (pressed) {
                const v = valueAt(ev.y);
                root.visualValue = v;
                root.moved(v);
            }
        }
        onReleased: {
            root.visualValue = root.value;
        }
    }
}
