import QtQuick
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

Item {
    id: root

    Component.onCompleted: Weather.subscribe()
    Component.onDestruction: Weather.unsubscribe()

    visible: Weather.ready

    implicitWidth:  row.implicitWidth + Appearance.layout.gapMd * 2
    implicitHeight: Appearance.bar.height

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Appearance.layout.gapSm
        anchors.bottomMargin: Appearance.layout.gapSm
        radius: Appearance.layout.radiusMd
        color: Appearance.colors.surfaceContainerLow
    }

    Row {
        id: row
        spacing: Appearance.layout.gapSm
        anchors.centerIn: parent

        MaterialIcon {
            text: Weather.glyph
            pixelSize: Appearance.typography.normal
            color: Appearance.colors.foreground
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: Math.round(Weather.temp) + "°"
            font.family: Config.typography.family
            font.pixelSize: Appearance.typography.small
            color: Appearance.colors.foreground
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
