import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

ChoreographerLoader {
    id: root

    property bool active: true

    // GridLayout binds its own implicitWidth from children, so wrap it in a
    // plain Item whose implicitWidth actually drives the popup size up through
    // the Loader → BarPopup.childrenRect chain.
    sourceComponent: Item {
        id: popupRoot
        implicitWidth: 308
        implicitHeight: popupGrid.implicitHeight

        readonly property int dayColWidth: 44
        readonly property int iconColWidth: 20
        readonly property int tempColWidth: 32

        function _isToday(d) {
            const now = new Date();
            return d.getFullYear() === now.getFullYear() && d.getMonth() === now.getMonth() && d.getDate()
                    === now.getDate();
        }

        ChoreographerGridLayout {
            id: popupGrid
            anchors.fill: parent
            columns: 1
            shown: root.active
            rowSpacing: Appearance.layout.gapLg

            FlyFadeEnterChoreographable {
                Layout.fillWidth: true

                StyledText {
                    text: "Weather"
                    font.pixelSize: Appearance.typography.large
                    font.weight: Font.Medium
                    color: Appearance.colors.accent
                }
            }

            FlyFadeEnterChoreographable {
                Layout.fillWidth: true

                RowLayout {
                    width: parent.width
                    spacing: Appearance.layout.gapMd

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 0

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.layout.gapSm

                            StyledText {
                                text: Math.round(Weather.temp) + "°"
                                font.pixelSize: Appearance.typography.huge
                                font.weight: Font.Medium
                                color: Appearance.colors.foreground
                            }
                            StyledText {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignBaseline
                                text: Weather.description ? Weather.description.charAt(0).toUpperCase()
                                                            + Weather.description.slice(1) : ""
                                font.pixelSize: Appearance.typography.normal
                                color: Appearance.colors.foreground
                                elide: Text.ElideRight
                            }
                        }

                        StyledText {
                            Layout.fillWidth: true
                            Layout.topMargin: Appearance.layout.gapXs
                            text: Config.weather.city + " · feels like " + Math.round(Weather.feelsLike) + "°"
                            font.pixelSize: Appearance.typography.smaller
                            color: Appearance.colors.m3onSurfaceInactive
                            elide: Text.ElideRight
                        }
                    }

                    MaterialIcon {
                        Layout.alignment: Qt.AlignVCenter
                        text: Weather.glyph
                        pixelSize: Appearance.typography.huge
                        color: Appearance.colors.foreground
                    }
                }
            }

            FlyFadeEnterChoreographable {
                Layout.fillWidth: true

                RowLayout {
                    width: parent.width
                    spacing: Appearance.layout.gapMd

                    Repeater {
                        model: [
                            {
                                icon: "water_drop",
                                value: Weather.humidity + "%"
                            },
                            {
                                icon: "air",
                                value: Weather.windSpeed.toFixed(1) + " m/s"
                            },
                            {
                                icon: "wb_twilight",
                                value: Qt.formatTime(Weather.sunrise, "hh:mm")
                            },
                            {
                                icon: "bedtime",
                                value: Qt.formatTime(Weather.sunset, "hh:mm")
                            }
                        ]
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Appearance.layout.gapXs

                            MaterialIcon {
                                text: modelData.icon
                                pixelSize: Appearance.typography.normal
                                color: Appearance.colors.m3onSurfaceVariant
                            }
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.value
                                font.pixelSize: Appearance.typography.small
                                color: Appearance.colors.foreground
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            FlyFadeEnterChoreographable {
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width
                    spacing: Appearance.layout.gapSm

                    StyledText {
                        text: "Next 24 hours"
                        font.pixelSize: Appearance.typography.smaller
                        font.weight: Font.Medium
                        color: Appearance.colors.m3onSurfaceVariant
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.layout.gapMd

                        Repeater {
                            model: Weather.hourly
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Appearance.layout.gapXs

                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: index === 0 ? "Now" : Qt.formatTime(modelData.time, "hh:mm")
                                    font.pixelSize: Appearance.typography.smaller
                                    color: Appearance.colors.m3onSurfaceInactive
                                }
                                MaterialIcon {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.glyph
                                    pixelSize: Appearance.typography.huge
                                    color: Appearance.colors.foreground
                                }
                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: Math.round(modelData.temp) + "°"
                                    font.pixelSize: Appearance.typography.small
                                    font.weight: Font.Medium
                                    color: Appearance.colors.foreground
                                }
                            }
                        }
                    }
                }
            }

            FlyFadeEnterChoreographable {
                Layout.fillWidth: true

                ColumnLayout {
                    width: parent.width
                    spacing: Appearance.layout.gapSm

                    StyledText {
                        text: "5-day forecast"
                        font.pixelSize: Appearance.typography.smaller
                        font.weight: Font.Medium
                        color: Appearance.colors.m3onSurfaceVariant
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Appearance.layout.gapSm

                        Repeater {
                            model: Weather.daily
                            RowLayout {
                                id: dayRow
                                Layout.fillWidth: true
                                spacing: Appearance.layout.gapMd

                                readonly property bool isToday: popupRoot._isToday(modelData.date)

                                StyledText {
                                    Layout.preferredWidth: popupRoot.dayColWidth
                                    text: dayRow.isToday ? "Today" : Qt.formatDate(modelData.date, "ddd")
                                    font.pixelSize: Appearance.typography.small
                                    font.weight: dayRow.isToday ? Font.Medium : Font.Normal
                                    color: dayRow.isToday ? Appearance.colors.accent :
                                                            Appearance.colors.foreground
                                }
                                MaterialIcon {
                                    Layout.preferredWidth: popupRoot.iconColWidth
                                    text: modelData.glyph
                                    pixelSize: Appearance.typography.normal
                                    color: Appearance.colors.foreground
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.condition
                                    font.pixelSize: Appearance.typography.small
                                    color: Appearance.colors.m3onSurfaceVariant
                                    elide: Text.ElideRight
                                }
                                StyledText {
                                    Layout.preferredWidth: popupRoot.tempColWidth
                                    horizontalAlignment: Text.AlignRight
                                    text: Math.round(modelData.tempMin) + "°"
                                    font.pixelSize: Appearance.typography.small
                                    color: Appearance.colors.m3onSurfaceInactive
                                }
                                StyledText {
                                    Layout.preferredWidth: popupRoot.tempColWidth
                                    horizontalAlignment: Text.AlignRight
                                    text: Math.round(modelData.tempMax) + "°"
                                    font.pixelSize: Appearance.typography.small
                                    font.weight: Font.Medium
                                    color: Appearance.colors.foreground
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
