import QtQuick
import QtQuick.Layouts
import qs.modules.common.widgets
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.models
import qs.services
import qs.modules.bar
import qs.modules.bar.popups

PressablePill {
    id: root

    property string cluster: "solo"

    readonly property bool _roundLeft: cluster === "start" || cluster === "solo"
    readonly property bool _roundRight: cluster === "end" || cluster === "solo"

    // Horizontal: drop the pill bg while this trigger's morph is open so the
    // morph shape reads as the bar expanding, not a panel slapped on top.
    readonly property bool morphActive: !Config.bar.vertical && BarPopouts.activeName === "weather"

    Component.onCompleted: Weather.subscribe()
    Component.onDestruction: Weather.unsubscribe()

    visible: Weather.ready

    implicitWidth: row.implicitWidth + Appearance.layout.gapMd * 2
    implicitHeight: Appearance.bar.height - Appearance.layout.gapSm * 2

    radius: Appearance.layout.radiusContainer
    topLeftRadius: _roundLeft ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    bottomLeftRadius: _roundLeft ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    topRightRadius: _roundRight ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    bottomRightRadius: _roundRight ? Appearance.layout.radiusContainer : Appearance.layout.radiusInner
    colorIdle: root.morphActive ? Appearance.colors.transparent : Appearance.colors.surfaceContainerLow
    useStateLayer: !root.morphActive   // no hover/press flash once it's the morph
    animateColor: !root.morphActive    // drop the pill bg instantly (no fade flash)
    pressScale: 0.98

    onClicked: {
        if (Config.bar.vertical)
            popupLoader.item.active = !popupLoader.item.active;
        else
            BarPopouts.toggle("weather", root);
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

    // Vertical bar keeps the original separate popup window; horizontal uses
    // the in-bar morph (BarPopouts → BarMorphPopout) instead.
    Loader {
        id: popupLoader
        active: Config.bar.vertical
        sourceComponent: BarPopup {
            id: popup
            targetItem: root
            padding: Appearance.layout.gapLg

            WeatherPopup {
                active: popup.active
            }
        }
    }
}
