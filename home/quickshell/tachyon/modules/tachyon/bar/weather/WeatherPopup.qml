pragma ComponentBehavior: Bound

import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import qs.modules.tachyon.bar

// Design "2a": glance card with hourly pills (claude.ai/design Weather Card)
StyledPopup {
    id: root

    readonly property var shapes: ({
        clear_day: MaterialShape.Shape.Sunny,
        clear_night: MaterialShape.Shape.Cookie12Sided,
        partly_cloudy_day: MaterialShape.Shape.Cookie9Sided,
        partly_cloudy_night: MaterialShape.Shape.Cookie9Sided,
        cloud: MaterialShape.Shape.Puffy,
        foggy: MaterialShape.Shape.Ghostish,
        rainy: MaterialShape.Shape.Clover4Leaf,
        thunderstorm: MaterialShape.Shape.Burst,
        weather_hail: MaterialShape.Shape.Gem,
        cloudy_snowing: MaterialShape.Shape.Flower,
        snowing: MaterialShape.Shape.Flower,
        snowing_heavy: MaterialShape.Shape.Flower,
    })

    // StyledPopup sizes itself from implicit sizes, which a ColumnLayout with
    // fillWidth rows underreports, so the width is pinned here (like Resources)
    Item {
        anchors.centerIn: parent
        implicitWidth: 280
        implicitHeight: column.implicitHeight

        ColumnLayout {
            id: column
            width: parent.width
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                MaterialShapeWrappedMaterialSymbol {
                    shape: root.shapes[Weather.data.icon] ?? MaterialShape.Shape.Cookie7Sided
                    text: Weather.data.icon ?? "cloud"
                    iconSize: 30
                    padding: 9
                    fill: 1
                    color: Appearance.colors.colPrimaryContainer
                    colSymbol: Appearance.colors.colOnPrimaryContainer
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        StyledText {
                            text: Weather.data.temp
                            font.pixelSize: 34
                            font.family: Appearance.font.family.numbers
                            color: Appearance.colors.colOnLayer1
                        }
                        StyledText {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignBaseline
                            text: Weather.data.desc ?? ""
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colOnLayer1
                            elide: Text.ElideRight
                        }
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: Translation.tr("Feels like %1").arg(Weather.data.tempFeelsLike) + "  •  H " + Weather.data.hi + "  L " + Weather.data.lo
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: Appearance.colors.colSubtext
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: pills.implicitHeight + 8
                radius: Appearance.rounding.verysmall
                color: Appearance.colors.colLayer3

                GridLayout {
                    id: pills
                    anchors.fill: parent
                    anchors.margins: 4
                    columns: 6
                    columnSpacing: 2
                    uniformCellWidths: true

                    Repeater {
                        model: Weather.data.hourly ?? []
                        Rectangle {
                            id: pill
                            required property var modelData
                            readonly property color fg: modelData.now ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer1
                            Layout.fillWidth: true
                            implicitHeight: pillColumn.implicitHeight + 18
                            radius: height / 2
                            color: modelData.now ? Appearance.colors.colPrimary : "transparent"

                            ColumnLayout {
                                id: pillColumn
                                anchors.centerIn: parent
                                spacing: 4

                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: pill.modelData.label
                                    font.pixelSize: Appearance.font.pixelSize.smaller
                                    color: pill.fg
                                }
                                MaterialSymbol {
                                    Layout.alignment: Qt.AlignHCenter
                                    fill: pill.modelData.now ? 1 : 0
                                    text: pill.modelData.icon
                                    iconSize: Appearance.font.pixelSize.larger
                                    color: pill.fg
                                }
                                StyledText {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: pill.modelData.temp
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    color: pill.fg
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
