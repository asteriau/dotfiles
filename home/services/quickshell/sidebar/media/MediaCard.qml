import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import qs.components.controls
import qs.components.text
import qs.utils
import qs.utils.state

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
            id: emptyState
            visible: root.activePlayer === null
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: 140
            Layout.maximumHeight: 140
            Layout.minimumHeight: 140

            readonly property real radius: Config.layout.mediaCardRadius

            RectangularShadow {
                anchors.fill: emptyBackground
                radius: emptyBackground.radius
                blur: 18
                offset: Qt.vector2d(0, Config.shadowVerticalOffset)
                spread: 1
                color: Colors.windowShadow
                cached: true
            }

            Rectangle {
                id: emptyBackground
                anchors.fill: parent
                anchors.margins: 4
                radius: emptyState.radius
                color: Colors.elevated

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: "transparent"
                    border.width: 1
                    border.color: Colors.cardBorder
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 15

                    Rectangle {
                        id: artSlot
                        Layout.fillHeight: true
                        implicitWidth: height
                        radius: 8
                        color: Colors.background

                        MaterialIcon {
                            anchors.centerIn: parent
                            text: "music_off"
                            fill: 1
                            font.pointSize: 28
                            color: Colors.accent
                        }
                    }

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        spacing: 2

                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignTop
                            lineHeightMode: Text.FixedHeight
                            lineHeight: 20
                            variant: StyledText.Variant.Subtitle
                            color: Colors.m3onSurfaceVariant
                            elide: Text.ElideRight
                            text: "No active player"
                        }
                        StyledText {
                            Layout.fillWidth: true
                            variant: StyledText.Variant.Caption
                            color: Colors.m3onSurfaceInactive
                            elide: Text.ElideRight
                            text: "Start something to see it here"
                        }

                        Item { Layout.fillHeight: true }

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: 32

                            StyledSlider {
                                anchors.left: parent.left
                                anchors.right: playGhost.left
                                anchors.rightMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                configuration: StyledSlider.Configuration.Wavy
                                animateWave: false
                                value: 0
                                enabled: false
                                opacity: 0.55
                                highlightColor: Colors.m3outline
                                trackColor: Colors.surfaceContainerHighest
                                handleColor: Colors.m3outline
                            }

                            RippleButton {
                                id: playGhost
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                property real size: 44
                                implicitWidth: size
                                implicitHeight: size
                                rippleEnabled: false
                                pointingHandCursor: false
                                buttonRadius: size / 2
                                opacity: 0.6
                                colBackground: Colors.surfaceContainerHighest
                                colBackgroundHover: Colors.surfaceContainerHighest
                                contentItem: MaterialIcon {
                                    text: "play_arrow"
                                    fill: 1
                                    font.pointSize: 16
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    color: Colors.m3onSurfaceVariant
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
