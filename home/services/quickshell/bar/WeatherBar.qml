import QtQuick
import qs.components.text
import qs.utils
import qs.services

Item {
    id: root

    Component.onCompleted: WeatherState.subscribe()
    Component.onDestruction: WeatherState.unsubscribe()

    visible: WeatherState.ready

    implicitWidth:  row.implicitWidth + Appearance.layout.gapMd * 2
    implicitHeight: Appearance.bar.height

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        radius: Appearance.layout.radiusMd
        color: Appearance.colors.surfaceContainerLow
    }

    Row {
        id: row
        spacing: 4
        anchors.centerIn: parent

        MaterialIcon {
            text: WeatherState.glyph
            pixelSize: Appearance.typography.normal
            color: Appearance.colors.foreground
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Math.round(WeatherState.temp) + "°"
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.small
            color: Appearance.colors.foreground
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
