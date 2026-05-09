pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.Mpris
import qs.utils
import qs.services

Item {
    id: root

    property MprisPlayer player: MprisState.player
    readonly property bool playing: player?.isPlaying ?? false
    property color accentColor: Colors.accent

    Row {
        anchors.centerIn: parent
        spacing: 3

        Repeater {
            model: 4
            Rectangle {
                required property int index
                width: 3
                height: 16
                radius: 1.5
                color: root.accentColor
                transformOrigin: Item.Center

                Behavior on color {
                    ColorAnimation { duration: M3Easing.durationMedium3; easing.type: Easing.OutCubic }
                }

                SequentialAnimation on scale {
                    running: root.playing
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.30; to: 1.00; duration: 360 + index * 90; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.00; to: 0.30; duration: 320 + index * 70; easing.type: Easing.InOutSine }
                }

                scale: root.playing ? scale : 0.32
                opacity: root.playing ? 1 : 0.55
                Behavior on opacity { NumberAnimation { duration: M3Easing.effectsDuration } }
            }
        }
    }
}
