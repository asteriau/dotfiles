import QtQuick
import QtQuick.Layouts
import qs.utils

Item {
    id: root

    property string icon
    property bool active
    signal clicked

    Layout.preferredWidth: 56
    Layout.preferredHeight: 56
    implicitWidth: 56
    implicitHeight: 56

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: width / 2
        color: root.active ? Colors.accent : Colors.elevated
        scale: ma.pressed ? 0.92 : 1.0
        antialiasing: true

        Behavior on color {
            ColorAnimation {
                duration: M3Easing.effectsDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: "Material Symbols Rounded"
        font.pixelSize: 24
        font.variableAxes: ({
                FILL: root.active ? 1 : 0,
                wght: root.active ? 500 : 400,
                opsz: 24,
                GRAD: 0
            })
        color: root.active ? Colors.m3onPrimary : Colors.m3onSurfaceVariant
        renderType: Text.NativeRendering

        Behavior on color {
            ColorAnimation {
                duration: M3Easing.effectsDuration
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
