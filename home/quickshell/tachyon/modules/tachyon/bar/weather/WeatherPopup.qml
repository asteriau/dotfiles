import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import qs.modules.tachyon.bar

// Same layout as main's weather popup, on this shell's wttr.in data
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

            StyledText {
                Layout.fillWidth: true
                text: Translation.tr("Weather")
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: Font.Medium
                color: Appearance.colors.colPrimary
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        StyledText {
                            text: Weather.data.temp
                            font.pixelSize: Appearance.font.pixelSize.huge
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer1
                        }
                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignBaseline
                            text: Weather.data.desc ?? ""
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colOnLayer1
                            elide: Text.ElideRight
                        }
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: Weather.data.city + " · " + Translation.tr("Feels like %1").arg(Weather.data.tempFeelsLike)
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                        elide: Text.ElideRight
                    }
                }

                MaterialSymbol {
                    Layout.alignment: Qt.AlignVCenter
                    fill: 0
                    text: Icons.getWeatherIcon(Weather.data.wCode) ?? "cloud"
                    iconSize: Appearance.font.pixelSize.hugeass + 8
                    color: Appearance.colors.colOnLayer1
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 8
                uniformCellWidths: true

                Repeater {
                    model: [
                        { icon: "humidity_low", value: Weather.data.humidity },
                        { icon: "air", value: Weather.data.wind },
                        { icon: "wb_twilight", value: Weather.data.sunrise },
                        { icon: "bedtime", value: Weather.data.sunset },
                        { icon: "wb_sunny", value: Translation.tr("UV %1").arg(Weather.data.uv) },
                        { icon: "rainy_light", value: Weather.data.precip },
                        { icon: "visibility", value: Weather.data.visib },
                        { icon: "readiness_score", value: Weather.data.press },
                    ]
                    RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 4

                        MaterialSymbol {
                            fill: 0
                            text: modelData.icon
                            iconSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colOnSurfaceVariant
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.value
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnLayer1
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
