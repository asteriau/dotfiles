import QtQuick
import QtQuick.Layouts
import qs.utils

Item {
    id: root

    property string icon
    property bool active
    property bool danger: false
    signal clicked

    Layout.fillWidth: true
    Layout.preferredHeight: width
    implicitWidth: 56
    implicitHeight: 56

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: root.active ? (root.danger ? Colors.red : Colors.accent) : Colors.elevated
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
        font.pixelSize: 22
        font.variableAxes: ({
                FILL: root.active ? 1 : 0,
                wght: 400,
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
