import QtQuick
import QtQuick.Layouts
import qs.utils

RowLayout {
    id: root
    Layout.fillWidth: true
    spacing: 12

    property date now: new Date()

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 2

        Text {
            text: Qt.formatDateTime(root.now, "HH:mm")
            color: Colors.foreground
            font.family: Config.fontFamily
            font.pixelSize: 22
            font.weight: Font.Medium
            font.letterSpacing: -0.44
        }

        Text {
            text: Qt.formatDateTime(root.now, "ddd d MMM")
            color: Colors.comment
            font.family: Config.fontFamily
            font.pixelSize: 12
        }
    }

    component IconBtn: Item {
        id: ib
        property string icon
        signal clicked

        Layout.preferredWidth: 36
        Layout.preferredHeight: 36

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: ma.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent"
            antialiasing: true
            Behavior on color {
                ColorAnimation {
                    duration: M3Easing.effectsDuration
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: ib.icon
            font.family: "Material Symbols Rounded"
            font.pixelSize: 18
            color: Colors.m3onSurfaceVariant
            renderType: Text.NativeRendering
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: ib.clicked()
        }
    }

    Item { Layout.fillWidth: true }

    IconBtn { icon: "edit" }
    IconBtn { icon: "power_settings_new" }
    IconBtn { icon: "settings" }
}
