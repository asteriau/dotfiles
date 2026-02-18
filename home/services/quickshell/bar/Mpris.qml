import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.utils
import qs.components

WrapperMouseArea {
    id: root
    Layout.fillHeight: true
    acceptedButtons: Qt.RightButton | Qt.LeftButton

    // Clicking anywhere toggles play/pause
    onClicked: event => {
        event.accepted = true
        if (MprisState.player) {
            MprisState.player.togglePlaying()
            playPauseButton.scale = 0.8
            playPauseButtonAnim.start()
        }
    }

    RowLayout {
        visible: MprisState.player
        Layout.fillHeight: true
        spacing: 8
        anchors.verticalCenter: parent.verticalCenter

        // Track info: artist - title
        Text {
            id: title
            text: {
                let artist = MprisState.player?.trackArtist || ""
                let track = MprisState.player?.trackTitle || ""
                artist && track ? `${artist} - ${track}` : track || artist || "No track"
            }
            color: Colors.mpris
            elide: Text.ElideRight
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
        }

        // Play/Pause Button on the right
        Text {
            id: playPauseButton
            text: MprisState.player?.isPlaying ? "" : ""
            color: Colors.mpris
            font.pixelSize: 20
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignVCenter
            scale: 1.0

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (MprisState.player) {
                        MprisState.player.togglePlaying()
                        playPauseButton.scale = 0.8
                        playPauseButtonAnim.start()
                    }
                }
            }

            // Animate icon press
            SequentialAnimation {
                id: playPauseButtonAnim
                running: false
                PropertyAnimation { target: playPauseButton; property: "scale"; to: 1.0; duration: 120; easing.type: Easing.OutQuad }
            }

            // Update icon when player changes state externally
            Connections {
                target: MprisState.player
                onIsPlayingChanged: {
                    playPauseButton.text = MprisState.player.isPlaying ? "" : ""
                }
            }
        }
    }
}
