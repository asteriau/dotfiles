import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services
import qs.modules.bar.popups

PressablePill {
    id: root

    property string cluster: "solo"

    readonly property bool _roundLeft:  cluster === "start" || cluster === "solo"
    readonly property bool _roundRight: cluster === "end"   || cluster === "solo"

    Component.onCompleted: Weather.subscribe()
    Component.onDestruction: Weather.unsubscribe()

    visible: Weather.ready

    implicitWidth:  row.implicitWidth + Appearance.layout.gapMd * 2
    implicitHeight: Appearance.bar.height - Appearance.layout.gapSm * 2

    radius: Appearance.layout.radiusContainer
    topLeftRadius:     _roundLeft  ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    bottomLeftRadius:  _roundLeft  ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    topRightRadius:    _roundRight ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    bottomRightRadius: _roundRight ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    colorIdle: Appearance.colors.surfaceContainerLow
    useStateLayer: true
    pressScale: 0.98

    onClicked: popup.active = !popup.active

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

    BarPopup {
        id: popup
        targetItem: root
        padding: Appearance.layout.gapLg

        WeatherPopup { active: popup.active }
    }
}
