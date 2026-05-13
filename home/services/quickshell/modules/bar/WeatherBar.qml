import QtQuick
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services

Item {
    id: root

    property string cluster: "solo"

    readonly property bool _roundLeft:  cluster === "start" || cluster === "solo"
    readonly property bool _roundRight: cluster === "end"   || cluster === "solo"

    Component.onCompleted: Weather.subscribe()
    Component.onDestruction: Weather.unsubscribe()

    visible: Weather.ready

    implicitWidth:  row.implicitWidth + Appearance.layout.gapMd * 2
    implicitHeight: Appearance.bar.height

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Appearance.layout.gapSm
        anchors.bottomMargin: Appearance.layout.gapSm
        topLeftRadius:     root._roundLeft  ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        bottomLeftRadius:  root._roundLeft  ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        topRightRadius:    root._roundRight ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
        bottomRightRadius: root._roundRight ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
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
