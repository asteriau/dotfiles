import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.components.controls
import qs.components.text
import qs.sidebar.media
import qs.utils
import qs.utils.state

Item {
    id: root

    readonly property MprisPlayer player: MprisState.player
    readonly property bool vertical: Config.bar.vertical
    property bool _popupOpen: false

    implicitWidth:  vertical ? 20 : rowLayout.implicitWidth
    implicitHeight: vertical ? 20 : Config.bar.height

    MouseArea {
        anchors.fill: parent
        hoverEnabled: false
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.BackButton | Qt.ForwardButton | Qt.RightButton

        onPressed: (event) => {
            if (event.button === Qt.LeftButton) {
                root._popupOpen = !root._popupOpen
            } else if (event.button === Qt.MiddleButton && root.player?.canTogglePlaying) {
                root.player.togglePlaying()
            } else if (event.button === Qt.BackButton && root.player?.canGoPrevious) {
                root.player.previous()
            } else if ((event.button === Qt.ForwardButton || event.button === Qt.RightButton) && root.player?.canGoNext) {
                root.player.next()
            }
        }
    }

    Timer {
        running: root.player?.isPlaying ?? false
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 4

        CircularProgress {
            id: circ
            Layout.alignment: Qt.AlignVCenter
            value: (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1)
            color: Colors.m3onSecondaryContainer

            Item {
                anchors.centerIn: parent
                width: circ.implicitSize
                height: circ.implicitSize

                MaterialIcon {
                    anchors.centerIn: parent
                    text: (root.player?.isPlaying ?? false) ? "pause" : "music_note"
                    fill: 1
                    pixelSize: Config.typography.normal
                    weight: Font.DemiBold
                    color: Colors.m3onSecondaryContainer
                }
            }
        }

        Text {
            id: trackLabel
            visible: !root.vertical && root.player !== null
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 200
            elide: Text.ElideRight
            font.family: Config.fontFamily
            font.pixelSize: Config.typography.small
            color: Colors.foreground
            text: {
                const title  = root.player?.trackTitle  ?? ""
                const artist = root.player?.trackArtist ?? ""
                if (title && artist) return `${title} • ${artist}`
                return title || artist || ""
            }
        }
    }

    BarPopup {
        targetItem: root
        active: root._popupOpen
        transparent: true

        Item {
            implicitWidth: 360
            implicitHeight: 160

            MediaCard {
                anchors.fill: parent
                showShadow: false
            }
        }
    }
}
