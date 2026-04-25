import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.components
import qs.utils

Item {
    id: root

    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.minimumHeight: 160

    readonly property var activePlayer: MprisState.player

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Repeater {
            model: root.activePlayer ? [root.activePlayer] : []
            delegate: PlayerControl {
                required property var modelData
                player: modelData
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                Layout.maximumHeight: 140
            }
        }

        Item {
            visible: root.activePlayer === null
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 140

            Rectangle {
                anchors.fill: parent
                anchors.margins: 4
                radius: 22
                color: Colors.elevated
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 14

                Item {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 72
                    Layout.preferredHeight: 72

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.12)
                        border.color: Qt.rgba(Colors.accent.r, Colors.accent.g, Colors.accent.b, 0.25)
                        border.width: 1
                        antialiasing: true
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        text: "music_off"
                        fill: 1
                        font.pointSize: 30
                        color: Colors.accent
                    }
                }

                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 2

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "No active player"
                        color: Colors.foreground
                        font.family: Config.fontFamily
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                        renderType: Text.NativeRendering
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Start something to see it here"
                        color: Colors.m3onSurfaceVariant
                        font.family: Config.fontFamily
                        font.pixelSize: 12
                        renderType: Text.NativeRendering
                    }
                }
            }
        }
    }
}
