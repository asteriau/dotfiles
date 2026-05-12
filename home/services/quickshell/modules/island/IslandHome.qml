pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

Item {
    id: root

    readonly property MprisPlayer player: MprisState.player
    readonly property bool hasMedia: player !== null

    property string timeText: ""
    property string dateText: ""

    Timer {
        running: root.visible
        interval: 1000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const d = new Date();
            root.timeText = Qt.formatDateTime(d, "HH:mm");
            root.dateText = Qt.formatDateTime(d, "ddd, MMM d");
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 22
        anchors.rightMargin: 22
        anchors.topMargin: 14
        anchors.bottomMargin: 14
        spacing: 22

        ColumnLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            spacing: 0

            Item { Layout.fillHeight: true }
            StyledText {
                variant: StyledText.Variant.Display
                font.pixelSize: 56
                font.weight: Font.Medium
                color: Appearance.colors.foreground
                text: root.timeText
            }
            StyledText {
                variant: StyledText.Variant.Caption
                color: Appearance.colors.foreground
                opacity: 0.65
                text: root.dateText
                Layout.topMargin: -6
            }
            Item { Layout.fillHeight: true }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                visible: root.hasMedia
                spacing: 10

                MaterialIcon {
                    text: root.player?.isPlaying ? "music_note" : "pause"
                    fill: 1
                    pixelSize: 18
                    color: Appearance.colors.accent
                }
                StyledText {
                    Layout.fillWidth: true
                    variant: StyledText.Variant.Body
                    color: Appearance.colors.foreground
                    elide: Text.ElideRight
                    text: {
                        const t = root.player?.trackTitle ?? "";
                        const a = root.player?.trackArtist ?? "";
                        return a ? `${t} — ${a}` : t;
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: BatteryState.present
                spacing: 10

                MaterialIcon {
                    text: BatteryState.charging ? "battery_charging_full" : "battery_5_bar"
                    fill: 1
                    pixelSize: 18
                    color: BatteryState.low ? "#e0c060"
                          : (BatteryState.charging ? Appearance.colors.accent : Appearance.colors.foreground)
                }
                StyledText {
                    Layout.fillWidth: true
                    variant: StyledText.Variant.Body
                    color: Appearance.colors.foreground
                    text: Math.round(BatteryState.level * 100) + "%"
                          + (BatteryState.charging ? " · Charging" : "")
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
