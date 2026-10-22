pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import qs.modules.tachyon.bar

// Same skeleton as ResourcesPopup: header, stat rows with a 2px bar, hourly grid
// (claude.ai/design "Weather Popup")
StyledPopup {
    id: root

    // StyledPopup sizes itself from implicit sizes, which a ColumnLayout with
    // fillWidth rows underreports, so the width is pinned here (like Resources)
    Item {
        anchors.centerIn: parent
        implicitWidth: 280
        implicitHeight: column.implicitHeight

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    Layout.fillWidth: true
                    text: Translation.tr("Weather")
                    font.pixelSize: Appearance.font.pixelSize.large
                    font.weight: Font.Medium
                    color: Appearance.colors.colPrimary
                }
                StyledText {
                    text: Weather.data.city
                    font.pixelSize: Appearance.font.pixelSize.smallie
                    color: Appearance.colors.colSubtext
                }
            }

            WeatherStatRow {
                icon: Weather.data.icon ?? "cloud"
                value: Weather.data.temp
                sub: Translation.tr("Feels like %1").arg(Weather.data.tempFeelsLike)
                label: Weather.data.desc ?? ""
                lo: Weather.data.lo
                hi: Weather.data.hi
                progress: Weather.data.rangeProgress
            }

            WeatherStatRow {
                icon: "wb_twilight"
                value: Weather.data.daylightLeft
                sub: Weather.data.night ? Translation.tr("until sunrise") : Translation.tr("until sunset")
                label: Weather.data.night ? Translation.tr("Night") : Translation.tr("Daylight")
                lo: Weather.data.night ? Weather.data.sunset : Weather.data.sunrise
                hi: Weather.data.night ? Weather.data.sunrise : Weather.data.sunset
                progress: Weather.data.dayProgress
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 6
                columnSpacing: 2
                uniformCellWidths: true

                Repeater {
                    model: Weather.data.hourly ?? []
                    Item {
                        id: slot
                        required property var modelData
                        readonly property color fg: modelData.now ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                        Layout.fillWidth: true
                        implicitHeight: slotColumn.implicitHeight + 8

                        ColumnLayout {
                            id: slotColumn
                            anchors.centerIn: parent
                            spacing: 4

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: slot.modelData.label
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: slot.modelData.now ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                            }
                            MaterialSymbol {
                                Layout.alignment: Qt.AlignHCenter
                                fill: slot.modelData.now ? 1 : 0
                                text: slot.modelData.icon
                                iconSize: 19
                                color: slot.fg
                            }
                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: slot.modelData.temp
                                font.pixelSize: Appearance.font.pixelSize.smallie
                                font.weight: slot.modelData.now ? Font.Medium : Font.Normal
                                color: slot.fg
                            }
                        }
                    }
                }
            }
        }
    }
}
