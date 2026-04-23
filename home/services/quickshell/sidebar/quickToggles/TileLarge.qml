import QtQuick
import QtQuick.Layouts
import qs.utils

Item {
    id: root

    property string icon
    property string label
    property string sub
    property bool active
    signal clicked

    Layout.fillWidth: true
    Layout.preferredHeight: 84
    implicitHeight: 84

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 28
        color: root.active ? Colors.accent : Colors.elevated
        scale: ma.pressed ? 0.97 : 1.0
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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignVCenter
            radius: 22
            color: root.active ? Qt.rgba(0.102, 0.145, 0.188, 0.18) : Colors.surfaceContainerHighest
            antialiasing: true

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
                color: root.active ? Colors.m3onPrimary : Colors.foreground
                renderType: Text.NativeRendering

                Behavior on color {
                    ColorAnimation {
                        duration: M3Easing.effectsDuration
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.label
                color: root.active ? Colors.m3onPrimary : Colors.foreground
                font.family: Config.fontFamily
                font.pixelSize: 14
                font.weight: Font.Medium
                font.letterSpacing: -0.14
                elide: Text.ElideRight

                Behavior on color {
                    ColorAnimation {
                        duration: M3Easing.effectsDuration
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.sub
                visible: root.sub.length > 0
                color: root.active ? Qt.rgba(Colors.m3onPrimary.r, Colors.m3onPrimary.g, Colors.m3onPrimary.b, 0.75) : Colors.m3onSurfaceVariant
                font.family: Config.fontFamily
                font.pixelSize: 11
                opacity: 0.8
                elide: Text.ElideRight
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
